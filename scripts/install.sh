#!/usr/bin/env bash

source scripts/_functions.sh

echo -e "\nSetting up epb dev tools\n"

clone_application "EPB Frontend" "https://github.com/communitiesuk/epb-frontend.git"
EPB_FRONTEND_PATH="$(printf "%q" "$CODEBASE_PATH")"

clone_application "EPB Data Frontend" "https://github.com/communitiesuk/epb-data-frontend.git"
EPB_DATA_FRONTEND_PATH="$(printf "%q" "$CODEBASE_PATH")"

clone_application "EPB Auth Server" "https://github.com/communitiesuk/epb-auth-server.git"
EPB_AUTH_SERVER_PATH="$(printf "%q" "$CODEBASE_PATH")"

clone_application "EPB Register API" "https://github.com/communitiesuk/epb-register-api.git"
EPB_REGISTER_API_PATH="$(printf "%q" "$CODEBASE_PATH")"

clone_application "EPB Data Warehouse" "https://github.com/communitiesuk/epb-data-warehouse.git"
EPB_DATA_WAREHOUSE_PATH="$(printf "%q" "$CODEBASE_PATH")"

clone_application "EPB Addressing" "https://github.com/communitiesuk/epb-addressing.git"
EPB_ADDRESSING_PATH="$(printf "%q" "$CODEBASE_PATH")"

EPB_FRONTEND_PATH=$EPB_FRONTEND_PATH \
EPB_DATA_FRONTEND_PATH=$EPB_DATA_FRONTEND_PATH \
EPB_AUTH_SERVER_PATH=$EPB_AUTH_SERVER_PATH \
EPB_REGISTER_API_PATH=$EPB_REGISTER_API_PATH \
EPB_DATA_WAREHOUSE_PATH=$EPB_DATA_WAREHOUSE_PATH \
EPB_ADDRESSING_PATH=$EPB_ADDRESSING_PATH \
generate_template

generate_tls_keys

# Are we running in vagrant?
if [[ "$USER" = "root" ]]; then
  echo "I think this is a vagrant environment, epb-proxy needs to run on a different port."

  echo "Moving port in docker-compose.yml"
  sed -i 's/80:80/8080:80/' docker-compose.yml

  echo "Setting port for forward services in vagrant nginx.conf"
  sudo sed -i 's#proxy_pass http://epb-frontend/;#proxy_pass http://epb-frontend:8080/;#' /etc/nginx/conf.d/default.conf
  sudo sed -i 's#proxy_pass http://epb-data-frontend/;#proxy_pass http://epb-data-frontend:8080/;#' /etc/nginx/conf.d/default.conf
  sudo sed -i 's#proxy_pass http://epb-auth-server/auth/;#proxy_pass http://epb-auth-server:8080/auth/;#' /etc/nginx/conf.d/default.conf
  sudo sed -i 's#proxy_pass http://epb-register-api/;#proxy_pass http://epb-register-api:8080/;#' /etc/nginx/conf.d/default.conf

  docker compose up -d
else
  bash scripts/rebuild.sh
fi

bash scripts/reset.sh

setup_hostsfile

setup_bash_profile
