# Manual Installation of Dev Tools

It is **highly** recommended that you use the installation script as mentioned
in the main [README](./README.md) file. Using this script will ensure that we
can support your use of this toolset for development. You may not be able to
take advantage of updates to this repo without using the automated installation.

**Requirements**

* docker
* docker-compose
* git
* bash 4 or greater (only if using installation scripts)

If you are running under windows, or you just want to manually install
rather than trusting a random script on the internet, you can do by following
these steps:

1. Create a new directory `MHCLG` to store the dev tools
2. Clone this repository into the `MHCLG` directory so it is located at
   `MHCLG/epb-dev-tools`
3. Clone the repository `git@github.com:communitiesuk/epb-register-api.git` to
    `MHCLG/epb-register-api`
4. Clone the repository `git@github.com:communitiesuk/epb-auth-server.git` to
    `MHCLG/epb-auth-server`
5. Clone the repository `git@github.com:communitiesuk/epb-frontend.git` to
    `MHCLG/epb-frontend`
6. Copy the file `docker-compose.template.yml` to `docker-compose.yml` and
    replace all instances with the following:
    1. `${PWD}` must be replaced with the FULL directory path to
        `MHCLG/epb-dev-tools`
    2. `${EPB_FRONTEND_PATH}` must be replaced with the FULL directory path to
        `MHCLG/epb-frontend`
    3. `${EPB_AUTH_SERVER_PATH}` must be replaced with the FULL path to
        `MHCLG/epb-auth-server`
    4. `${EPB_REGISTER_API_PATH}` must be replaced with the FULL path to
        `MHCLG/epb-register-api`
7. From the directory `MHCLG/epb-dev-tools` run the following commands:
    1. `docker-compose build` to build the docker images needed to run the tools
    2. `docker-compose up -d` to bring up the infrastructure
    3. wait, check the logs to ensure all services are running.
        (`docker-compose logs -f`)
    4. Setup DBs:
        1. Setup the authentication service

            ```sh
            docker-compose exec -T epb-auth-server bash -c 'cd /app && make db-setup'

            docker-compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO clients (id, name, supplemental) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'epb_frontend', '{\\\"scheme_ids\\\": [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]}');\""

            docker-compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO clients (id, name, supplemental) VALUES ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', 'epb_data_warehouse', '{\\\"scheme_ids\\\": [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]}');\""

            docker-compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_secrets (client_id, secret) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', crypt('test-client-secret', gen_salt('bf')));\""

            docker-compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_secrets (client_id, secret) VALUES ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', crypt('data-warehouse-secret', gen_salt('bf')));\""

            docker-compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_scopes (client_id, scope) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:create'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:list'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:assessor:list'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:assessor:update'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'scheme:assessor:fetch'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:fetch'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:lodge'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessment:search'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'assessor:search'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'address:search'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'migrate:assessment'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'migrate:assessor'),  ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'migrate:address'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'report:assessor:status'), ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'statistics:fetch');\""
            
            docker-compose exec -T epb-auth-server-db bash -c "psql --username epb -d epb -c \"INSERT INTO client_scopes (client_id, scope) VALUES ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', 'assessment:fetch'), ('5e7b7607-971b-45a4-9155-cb4f6ea7e9f5', 'assessmentmetadata:fetch');\""
            ```


        2. Setup register API service

            ```sh
            docker-compose exec -T epb-register-api bash -c 'cd /app && RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 make setup-db'
            ```

            Note: The next process can take up to 20 minutes, even on modern
            hardware.

            ```sh
            docker-compose exec epb-register-api bash -c 'cd /app && bundle exec rake maintenance:import_postcode'
            
            docker-compose exec epb-register-api bash -c 'cd /app && bundle exec rake dev_data:import_postcode_outcode'

            docker-compose exec epb-register-api bash -c 'cd /app && bundle exec rake dev_data:generate_schemes'

            docker-compose exec epb-register-api bash -c 'cd /app && bundle exec rake dev_data:generate_assessors'
            ```
        3. Setup Frontend

            `docker-compose exec -T epb-frontend bash -c 'cd /app && npm install && make frontend-build'`

        4. Setup Data Warehouse
            ```sh
              docker-compose exec -T epb-data-warehouse bash -c 'cd /app && RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:migrate || bundle exec rake db:setup'
            ```
8. Add the following line to your hosts file (`/etc/hosts` for macOS and most
    linux distros) `127.0.0.1 getting-new-energy-certificate.epb-frontend find-energy-certificate.epb-frontend getting-new-energy-certificate.local.gov.uk find-energy-certificate.local.gov.uk epb-frontend epb-register-api epb-auth-server epb-feature-flag`

9. Add the following line to either your `.zshrc` or `.bashrc` files:
    `alias epb="$PATH/MHCLG/epb-dev-tools/epb"` where `$PATH` is the full path
    to the folder containing the `MHCLG` folder created earlier.
