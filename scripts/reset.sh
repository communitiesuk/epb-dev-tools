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

  # Setup db and other essentials
  printf "$GREEN Setting up Auth Server $CLEAR \n"
  docker compose exec -T epb-auth-server bash -c 'cd /app && make db-setup'
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO clients (id, name, supplemental) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'epb_frontend', '{\\\"scheme_ids\\\": [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]}');\""
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO clients (id, name, supplemental) VALUES ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', 'epb_data_warehouse', '{\\\"scheme_ids\\\": [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]}');\""
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_secrets (client_id, secret) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', crypt('test-client-secret', gen_salt('bf')));\""
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_secrets (client_id, secret) VALUES ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', crypt('data-warehouse-secret', gen_salt('bf')));\""
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_scopes (client_id, scope) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:create'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:list'),  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'client:create'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'client:fetch'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'client:update'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'client:delete'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:assessor:list'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:assessor:update'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:assessor:fetch'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:fetch'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:lodge'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:search'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessor:search'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'address:search'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'migrate:assessment'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'migrate:assessor'),  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'migrate:address'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'report:assessor:status'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'statistics:fetch'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'warehouse:read'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'epb-data-front:read');\""
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_scopes (client_id, scope) VALUES ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', 'assessment:fetch'), ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', 'assessmentmetadata:fetch');\""

  printf "$GREEN Setting up Register API $CLEAR \n"
  docker compose exec -T epb-register-api bash -c 'cd /app && RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 make setup-db'

  printf "$GREEN Setting up Frontend $CLEAR \n"
  docker compose exec -T epb-frontend bash -c 'cd /app && npm install && make frontend-build'

  printf "$GREEN Setting up Data Warehouse $CLEAR \n"
  docker compose exec -T epb-data-warehouse bash -c 'cd /app && RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:migrate || bundle exec rake db:setup'

  printf "$GREEN Setting up Feature Flags $CLEAR \n"
  docker compose exec -T epb-feature-flag-db bash -c "psql --username unleashed -d unleashed -c \"UPDATE environments set enabled = true where name = 'default';\""
  docker compose exec -T epb-feature-flag-db bash -c "psql --username unleashed -d unleashed -c \"UPDATE environments set protected = false where name = 'default';\""
  docker compose exec -T epb-feature-flag-db bash -c "psql --username unleashed -d unleashed -c \"INSERT into project_environments (project_id, environment_name) VALUES ('default', 'default');\""
  docker compose exec -T epb-feature-flag-db bash -c "psql --username unleashed -d unleashed -c \"INSERT into features (name) VALUES ('register-api-read-only-mode');\""
  docker compose exec -T epb-feature-flag-db bash -c "psql --username unleashed -d unleashed -c \"INSERT into feature_environments (environment, feature_name, enabled, variants) VALUES ('default', 'register-api-read-only-mode', true, '[]');\""
fi
