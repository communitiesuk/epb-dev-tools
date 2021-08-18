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
    4. Setup the auth server:
        1. Setup the authentication server

            `docker-compose exec epb-auth-server bash -c 'cd /app && make
            db-setup'`

            `docker-compose exec epb-auth-server-db bash -c "psql --username epb
             -d epb -c \"INSERT INTO clients (id, name, secret) VALUES
             ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'epb_frontend',
             'test-client-secret');\""`

        2. Setup the register API server

            `docker-compose exec epb-register-api bash -c 'cd /app && make
            setup-db'`

            Note: The next process can take up to 20 minutes, even on modern
            hardware.

            `docker-compose exec epb-register-api bash -c 'cd /app && bundle
            exec rake maintenance:import_postcode'`

            `docker-compose exec epb-register-api bash -c 'cd /app && bundle
            exec rake dev_data:import_postcode_outcode'`

            `docker-compose exec epb-register-api bash -c 'cd /app && bundle
            exec rake dev_data:generate_schemes'`

            `docker-compose exec epb-register-api bash -c 'cd /app && bundle
            exec rake dev_data:generate_assessors'`

8. Add the following line to your hosts file (`/etc/hosts` for macOS and most
    linux distros) `127.0.0.1 epb-frontend epb-auth-server epb-register-api`

9. Add the following line to either your `.zshrc` or `.bashrc` files:
    `alias epb="$PATH/MHCLG/epb-dev-tools/epb"` where `$PATH` is the full path
    to the folder containing the `MHCLG` folder created earlier.
