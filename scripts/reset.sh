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
  docker-compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO clients (id, name, supplemental) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'epb_frontend', '{\\\"scheme_ids\\\": [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]}');\""
  docker-compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_secrets (client_id, secret) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', crypt('test-client-secret', gen_salt('bf')));\""
  docker-compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_scopes (client_id, scope) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:create'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:list'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:assessor:list'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:assessor:update'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:assessor:fetch'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:fetch'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:lodge'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:search'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessor:search'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'address:search'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'migrate:assessment'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'migrate:assessor'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'migrate:address'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'report:assessor:status');\""

  echo "Setting up Register API"
  docker-compose exec -T epb-register-api bash -c 'cd /app && RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 make setup-db'
  docker-compose exec -T epb-register-api bash -c 'cd /app && RACK_ENV=production bundle exec rake import_postcode'
  docker-compose exec -T epb-register-api bash -c 'cd /app && RACK_ENV=production bundle exec rake import_postcode_outcode'
  docker-compose exec -T epb-register-api bash -c 'cd /app && RACK_ENV=production bundle exec rake generate_schemes'
  docker-compose exec -T epb-register-api bash -c 'cd /app && RACK_ENV=production bundle exec rake generate_assessor'
  docker-compose exec -T epb-register-api bash -c 'cd /app && RACK_ENV=production bundle exec rake generate_certificate'

  echo "Setting up Frontend"
  docker-compose exec -T epb-frontend bash -c 'cd /app && yarn install && make frontend-build'
fi
