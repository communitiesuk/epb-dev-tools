#!/usr/bin/env bash

docker compose exec -T epb-register-api bash -c 'cd /app && bundle exec rake dev_data:lodge_dev_assessment'
