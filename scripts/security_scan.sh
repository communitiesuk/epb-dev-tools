#!/usr/bin/env bash

source scripts/_functions.sh

OPEN_API_SPEC_JSON=$(cat "$DIR/../../epb-register-api/config/apidoc.yml" | y2j)

LOCAL_TESTING_API_SPEC=$(echo "$OPEN_API_SPEC_JSON" | jq '.servers = [{"url":"http://epb-register-api/api", "description": "Local Testing Server"}]')

echo "$LOCAL_TESTING_API_SPEC" > "$DIR/../http_files/api-spec.json"

PROXY_SERVER_IP=$(docker inspect epb-dev-tools_epb-proxy_1 | jq -r '.[0].NetworkSettings.Networks["epb-dev-tools_default"].IPAddress')
AUTH_TOKEN=$(curl -s -X POST http://epb-register-api/auth/oauth/token -H 'Content-Length: 0' -H 'Authorization: Basic NmY2MTU3OWUtZTgyOS00N2Q3LWFlZjUtN2QzNmFkMDY4YmVlOnRlc3QtY2xpZW50LXNlY3JldA==' | jq -r '.access_token')

if [ ! -d "$DIR/../security-reports" ]; then mkdir -p "$DIR/../security-reports"; fi

docker run -it \
  --network=epb-dev-tools_default \
  --add-host=epb-register-api:$PROXY_SERVER_IP \
  --volume=$DIR/../security-reports:/zap/wrk  \
  owasp/zap2docker-stable \
  zap-api-scan.py \
  -t http://epb-register-api/test_files/api-spec.json \
  -f openapi \
  -w "$(date +%s)-report.md" \
  -z "-config replacer.full_list(0).description=oauth
  -config replacer.full_list(0).enabled=true
  -config replacer.full_list(0).matchtype=REQ_HEADER
  -config replacer.full_list(0).matchstr=Authorization
  -config replacer.full_list(0).regex=false
  -config replacer.full_list(0).replacement='Bearer $AUTH_TOKEN'"
