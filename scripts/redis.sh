#!/usr/bin/env bash

docker-compose \
exec "$APP" \
bash -c "redis-cli"
