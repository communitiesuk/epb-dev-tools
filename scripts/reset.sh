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
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO clients (id, name, supplemental) VALUES ('bcef78ba-8e31-4639-8dc7-0754d1f67db8', 'epb_register_api', '{\\\"scheme_ids\\\": [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]}');\""
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO clients (id, name, supplemental) VALUES ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'epb_local_security_scan', '{\\\"scheme_ids\\\": [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]}');\""

  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_secrets (client_id, secret) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', crypt('test-client-secret', gen_salt('bf')));\""
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_secrets (client_id, secret) VALUES ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', crypt('data-warehouse-secret', gen_salt('bf')));\""
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_secrets (client_id, secret) VALUES ('bcef78ba-8e31-4639-8dc7-0754d1f67db8', crypt('register-api-secret', gen_salt('bf')));\""
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_secrets (client_id, secret) VALUES ('a084abff-c22d-4b78-875c-1e7b163c5ee3', crypt('security-scan-secret', gen_salt('bf')));\""

  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_scopes (client_id, scope) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:create'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:list'),  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'client:create'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'client:fetch'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'client:update'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'client:delete'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:assessor:list'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:assessor:update'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:assessor:fetch'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:fetch'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:lodge'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:search'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessor:search'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'address:search'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'migrate:assessment'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'migrate:assessor'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'migrate:address'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'report:assessor:status'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'statistics:fetch'),
  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'warehouse:read'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'epb-data-front:read');\""
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_scopes (client_id, scope) VALUES ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', 'assessment:fetch'), ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', 'assessmentmetadata:fetch');\""
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_scopes (client_id, scope) VALUES ('bcef78ba-8e31-4639-8dc7-0754d1f67db8', 'addressing:read');\""
  docker compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_scopes (client_id, scope) VALUES ('a084abff-c22d-4b78-875c-1e7b163c5ee3', ''),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'address:search'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'admin:opt_out'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'admin:update-address-id'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'admin:upload_stats'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'assessment:domestic-epc:search'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'assessment:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'assessment:lodge'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'assessment:search'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'assessor:search'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'bus:assessment:search'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'client:create'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'client:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'client:update'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'dec_summary:fetch'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'domestic_epc:assessment:search'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'ecoplus:assessment:fetch'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'greendeal:charge-updates'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'greendeal:plans'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'heat-pump-check:assessment:fetch'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'prsdatabase:assessment:search'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'report:assessor:status'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'retrofit-advice:assessment:fetch'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'retrofit-advice:assessment:search'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'retrofit-funding:assessment:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scheme:assessor:fetch'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scheme:assessor:list'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scheme:assessor:update'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scheme:create'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scheme:list'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'statistics:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'warm-home-discount:assessment:fetch'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scotland_assessment:lodge'),('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'migrate:scotland'),
  ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scotland_assessment:fetch'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scotland_assessment:search'), ('a084abff-c22d-4b78-875c-1e7b163c5ee3', 'scotland_assessor:search')
  ;\""

  printf "$GREEN Setting up Register API $CLEAR \n"
  docker compose exec -T epb-register-api bash -c 'cd /app && RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 make setup-db'

  printf "$GREEN Setting up Frontend $CLEAR \n"
  docker compose exec -T epb-frontend bash -c 'cd /app && npm install && make frontend-build'

  printf "$GREEN Setting up Data Warehouse $CLEAR \n"
  docker compose exec -T epb-data-warehouse bash -c 'cd /app && RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:migrate || bundle exec rake db:setup'

  printf "$GREEN Setting up Data Frontend $CLEAR \n"
  docker compose exec -T epb-data-frontend bash -c 'cd /app && npm install && make frontend-build'

  printf "$GREEN Setting up Addressing $CLEAR \n"
  docker compose exec -T epb-addressing bash -c 'cd /app && RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 make setup-db'

  printf "$GREEN Setting up Feature Flags $CLEAR \n"
  docker compose exec -T epb-feature-flag-db bash -c "psql --username unleashed -d unleashed -c \"delete from environments where name = 'production';\""

  docker compose exec -T epb-feature-flag-db bash -c "psql --username unleashed -d unleashed -c \"INSERT into features (name) VALUES ('register-api-read-only-mode') ON CONFLICT (name) DO NOTHING;\""
  docker compose exec -T epb-feature-flag-db bash -c "psql --username unleashed -d unleashed -c \"INSERT into feature_environments (environment, feature_name, enabled, variants) VALUES ('development', 'register-api-read-only-mode', false, '[]') ON CONFLICT (environment, feature_name) DO NOTHING;\""
  docker compose exec -T epb-feature-flag-db bash -c "psql --username unleashed -d unleashed -c \"INSERT into features (name) VALUES ('epb-frontend-data-restrict-user-access') ON CONFLICT (name) DO NOTHING;\""
  docker compose exec -T epb-feature-flag-db bash -c "psql --username unleashed -d unleashed -c \"INSERT into feature_environments (environment, feature_name, enabled, variants) VALUES ('development', 'epb-frontend-data-restrict-user-access', false, '[]') ON CONFLICT (environment, feature_name) DO NOTHING;\""
  docker compose exec -T epb-feature-flag-db bash -c "psql --username unleashed -d unleashed -c \"INSERT into features (name) VALUES ('block-address-matching-during-lodgement') ON CONFLICT (name) DO NOTHING;\""
  docker compose exec -T epb-feature-flag-db bash -c "psql --username unleashed -d unleashed -c \"INSERT into feature_environments (environment, feature_name, enabled, variants) VALUES ('development', 'block-address-matching-during-lodgement', false, '[]') ON CONFLICT (environment, feature_name) DO NOTHING;\""

fi
