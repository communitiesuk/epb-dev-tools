#!/usr/bin/env bash

docker compose exec -T epb-register-api bash -c 'bundle exec rake dev_data:lodge_dev_assessment'
