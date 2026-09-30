#!/usr/bin/env bash

docker run \
  -it \
  --rm \
  --entrypoint bash \
  --network epb-dev-tools_default \
  -e AWS_ENDPOINT_URL=http://dynamodb-local:8000 \
  -e AWS_ACCESS_KEY_ID=dummy \
  -e AWS_SECRET_ACCESS_KEY=dummy \
  -e AWS_REGION=eu-west-2 \
  amazon/aws-cli
