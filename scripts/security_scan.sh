#!/usr/bin/env bash

set -e

source scripts/_functions.sh

REGISTER_OPEN_API_SPEC_JSON=$(cat "$DIR/../../epb-register-api/api/api.yml" | yq eval -o=j)
REGISTER_LOCAL_TESTING_API_SPEC=$(echo "$REGISTER_OPEN_API_SPEC_JSON" | jq '.servers = [{"url":"http://epb-register-api/api", "description": "Local Testing Server"}]')
echo "$REGISTER_LOCAL_TESTING_API_SPEC" > "$DIR/../http_files/register-api-spec.json"

WAREHOUSE_OPEN_API_SPEC_JSON=$(cat "$DIR/../../epb-data-warehouse/api/api.yml" | yq eval -o=j)
WAREHOUSE_LOCAL_TESTING_API_SPEC=$(echo "$WAREHOUSE_OPEN_API_SPEC_JSON" | jq '.servers = [{"url":"http://epb-data-warehouse-api", "description": "Local Testing Server"}]')
echo "$WAREHOUSE_LOCAL_TESTING_API_SPEC" > "$DIR/../http_files/warehouse-api-spec.json"

AUTH_OPEN_API_SPEC_JSON=$(cat "$DIR/../../epb-auth-server/config/apidoc.yml" | yq eval -o=j)
AUTH_LOCAL_TESTING_API_SPEC=$(echo "$AUTH_OPEN_API_SPEC_JSON" | jq '.servers = [{"url":"http://epb-register-api/auth", "description": "Local Testing Server"}]')
echo "$AUTH_LOCAL_TESTING_API_SPEC" > "$DIR/../http_files/auth-api-spec.json"

PROXY_SERVER_CONTAINER=$(docker container ls --format "{{json . }}" | jq -rs '.[] | select(.Names|contains("epb-proxy")) | .Names')
echo "Found proxy server: $PROXY_SERVER_CONTAINER"

PROXY_SERVER_IP=$(docker inspect $PROXY_SERVER_CONTAINER | jq -r '.[0].NetworkSettings.Networks["epb-dev-tools_default"].IPAddress')
echo "Found proxy server IP: $PROXY_SERVER_IP"

SCAN_DATE=$(date +%F_%H%M)

if [ ! -d "$DIR/../security-reports" ]; then mkdir -p "$DIR/../security-reports"; fi

docker pull ghcr.io/zaproxy/zaproxy:stable

echo -e "-> Running Zap baseline scan against the frontend application";

docker run -it \
  --network=epb-dev-tools_default \
  --add-host=find-energy-certificate.epb-frontend:$PROXY_SERVER_IP \
  --volume=$DIR/../security-reports:/zap/wrk  \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -I \
  -t http://find-energy-certificate.epb-frontend/ \
  -r "$SCAN_DATE-frontend-report.html" \
  -w "$SCAN_DATE-frontend-report.md"

  echo -e "-> Running Zap baseline scan against the EPC data frontend application";

  docker run -it \
    --network=epb-dev-tools_default \
    --volume=$DIR/../security-reports:/zap/wrk  \
    ghcr.io/zaproxy/zaproxy:stable \
    zap-baseline.py \
    -I \
    -t http://epb-data-frontend/ \
    -r "$SCAN_DATE-data-frontend-report.html" \
    -w "$SCAN_DATE-data-frontend-report.md"


# The auth header here is Base64 encoding of the security scan client ID and client secret defined in reset.sh
# a084abff-c22d-4b78-875c-1e7b163c5ee3:all-scopes-secret
AUTH_TOKEN=$(curl -s -X POST http://epb-register-api/auth/oauth/token -H 'Content-Length: 0' -H 'Authorization: Basic YTA4NGFiZmYtYzIyZC00Yjc4LTg3NWMtMWU3YjE2M2M1ZWUzOmFsbC1zY29wZXMtc2VjcmV0' | jq -r '.access_token')

echo -e "-> Running Zap api scan against the auth api using the api spec";

docker run -it \
  --network=epb-dev-tools_default \
  --add-host=epb-register-api:$PROXY_SERVER_IP \
  --volume=$DIR/../security-reports:/zap/wrk  \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py \
  -I \
  -t http://epb-register-api/test_files/auth-api-spec.json \
  -f openapi \
  -r "$SCAN_DATE-auth-api-report.html" \
  -w "$SCAN_DATE-auth-api-report.md" \
  -z "-config replacer.full_list(0).description=oauth
  -config replacer.full_list(0).enabled=true
  -config replacer.full_list(0).matchtype=REQ_HEADER
  -config replacer.full_list(0).matchstr=Authorization
  -config replacer.full_list(0).regex=false
  -config replacer.full_list(0).replacement='Bearer $AUTH_TOKEN'"

echo -e "-> Running Zap api scan against the api using the api spec";

docker run -it \
  --network=epb-dev-tools_default \
  --add-host=epb-register-api:$PROXY_SERVER_IP \
  --volume=$DIR/../security-reports:/zap/wrk  \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py \
  -I \
  -t http://epb-register-api/test_files/api-spec.json \
  -f openapi \
  -r "$SCAN_DATE-api-report.html" \
  -w "$SCAN_DATE-api-report.md" \
  -z "-config replacer.full_list(0).description=oauth
  -config replacer.full_list(0).enabled=true
  -config replacer.full_list(0).matchtype=REQ_HEADER
  -config replacer.full_list(0).matchstr=Authorization
  -config replacer.full_list(0).regex=false
  -config replacer.full_list(0).replacement='Bearer $AUTH_TOKEN'"

echo -e "-> Running Zap api scan against the warehouse api using the warehouse api spec";

docker run -it \
  --network=epb-dev-tools_default \
  --add-host=epb-data-warehouse-api:$PROXY_SERVER_IP \
  --volume=$DIR/../security-reports:/zap/wrk  \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py \
  -I \
  -t http://epb-data-warehouse-api/test_files/warehouse-api-spec.json \
  -f openapi \
  -r "$SCAN_DATE-warehouse-api-report.html" \
  -w "$SCAN_DATE-warehouse-api-report.md" \
  -z "-config replacer.full_list(0).description=oauth
  -config replacer.full_list(0).enabled=true
  -config replacer.full_list(0).matchtype=REQ_HEADER
  -config replacer.full_list(0).matchstr=Authorization
  -config replacer.full_list(0).regex=false
  -config replacer.full_list(0).replacement='Bearer hqhNzxZCu6wwBMY9Kte98I'"
