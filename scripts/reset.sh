#!/usr/bin/env bash

source scripts/_functions.sh

echo "OVERRIDE SET TO $OVERRIDE_CONFIRM"

if [[ -z $(confirm "Do you want to reset and configure the dev environment?") ]]; then
  echo "Bailing from reset"
else
  echo "Waiting for postgres to be up and running."
  until_accepting_connections "epb-dev-tools_epb-auth-server-db_1"
  until_accepting_connections "epb-dev-tools_epb-feature-flag-db_1"
  until_accepting_connections "epb-dev-tools_epb-register-api-db_1"

  # Setup db and other essentials
  echo "Setting up Auth Server"
  docker-compose exec -T epb-auth-server bash -c 'cd /app && make db-setup'
  docker-compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO clients (id, name, secret) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'epb_frontend', 'test-client-secret');\""

  echo "Setting up Register API"
  docker-compose exec -T epb-register-api bash -c 'cd /app && make setup-db'
  docker-compose exec -T epb-register-api bash -c 'cd /app && bundle exec rake import_postcode'
  docker-compose exec -T epb-register-api bash -c 'cd /app && bundle exec rake import_postcode_outcode'
  docker-compose exec -T epb-register-api bash -c 'cd /app && bundle exec rake generate_schemes'
  docker-compose exec -T epb-register-api bash -c 'cd /app && bundle exec rake generate_assessor'
  docker-compose exec -T epb-register-api bash -c 'cd /app && bundle exec rake generate_certificate'

  echo "Setting up Frontend"
  docker-compose exec -T epb-frontend bash -c 'cd /app && yarn install && make frontend-build'
fi
