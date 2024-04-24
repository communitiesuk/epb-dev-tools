#!/usr/bin/env bash

DOCKER_SERVICE_NAME=$APP

docker compose \
exec "$DOCKER_SERVICE_NAME-db" \
bash -c "psql --username epb -d epb"
