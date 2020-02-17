#!/usr/bin/env bash

source scripts/_functions.sh

if [[ -n $(confirm "Do you want to reset and configure the dev environment?") ]]; then
  # Ensure images are built
  docker-compose down
  docker-compose rm -f
  docker-compose build
  docker-compose up -d

  echo "Waiting for postgres to be up and running."
  sleep 10

  # Setup db and other essentials
  docker-compose exec epb-auth-server bash -c 'cd /app && make db-setup'
  docker-compose exec epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO clients (id, name, secret) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'epb_frontend', 'test-client-secret');\""

  docker-compose exec epb-register-api bash -c 'cd /app && make setup-db'
  docker-compose exec epb-register-api bash -c 'cd /app && bundle exec rake import_postcode'
  docker-compose exec epb-register-api bash -c 'cd /app && bundle exec rake import_postcode_outcode'
  docker-compose exec epb-register-api bash -c 'cd /app && bundle exec rake generate_schemes'
  docker-compose exec epb-register-api bash -c 'cd /app && bundle exec rake generate_assessor'
fi
