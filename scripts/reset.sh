#!/usr/bin/env bash

source scripts/_functions.sh

echo "OVERRIDE SET TO $OVERRIDE_CONFIRM"

RED='\033[0;31m'
GREEN='\033[0;32m'
CLEAR='\033[0m' #

if [[ -z $(confirm "Do you want to reset and configure the dev environment?") ]]; then
  echo "Bailing from reset"
else
  echo "Waiting for postgres to be up and running"
  until_accepting_connections "epb-dev-tools-epb-auth-server-db-1"
  echo "Auth DB OK"
  until_accepting_connections "epb-dev-tools-epb-feature-flag-db-1"
  echo "Toggles DB OK"
  until_accepting_connections "epb-dev-tools-epb-register-api-db-1"
  echo "API DB OK"
  until_accepting_connections "epb-dev-tools-epb-data-warehouse-db-1"
  echo "Data warehouse DB OK"

  printf "$GREEN Setting up Auth Server $CLEAR \n"
  docker compose exec -T epb-auth-server bash -c 'make db-setup'
  docker compose exec -T epb-auth-server-db psql -U epb -d epb < ./scripts/seed_auth_server.sql

  printf "$GREEN Setting up Register API $CLEAR \n"
  docker compose exec -T epb-register-api bash -c 'RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 make setup-db'

  printf "$GREEN Setting up Frontend $CLEAR \n"
  docker compose exec -T epb-frontend bash -c 'npm install && make frontend-build'

  printf "$GREEN Setting up Data Warehouse $CLEAR \n"
  docker compose exec -T epb-data-warehouse bash -c 'RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:migrate || bundle exec rake db:setup'

  printf "$GREEN Setting up Data Frontend $CLEAR \n"
  docker compose exec -T epb-data-frontend bash -c 'npm install && make frontend-build'

  printf "$GREEN Setting up Addressing $CLEAR \n"
  docker compose exec -T epb-addressing bash -c 'RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 make setup-db'

  printf "$GREEN Setting up Feature Flags $CLEAR \n"
  docker compose exec -T epb-feature-flag-db psql -U unleashed -d unleashed < ./scripts/seed_unleashed.sql
fi
