#!/usr/bin/env bash

DOCKER_SERVICE_NAME=$1
DOCKER_SERVICE_USERNAME=$2

docker-compose \
exec "$DOCKER_SERVICE_NAME-db" \
bash -c "psql --username $DOCKER_SERVICE_USERNAME -d $DOCKER_SERVICE_USERNAME"
