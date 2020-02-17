#!/usr/bin/env bash

source scripts/_functions.sh

echo -e "\nSetting up epb dev tools\n"

clone_application "EPB Frontend" "git@github.com:communitiesuk/epb-frontend.git"
EPB_FRONTEND_PATH="$(printf "%q" "$CODEBASE_PATH")"

clone_application "EPB Auth Server" "git@github.com:communitiesuk/epb-auth-server.git"
EPB_AUTH_SERVER_PATH="$(printf "%q" "$CODEBASE_PATH")"

clone_application "EPB Register API" "git@github.com:communitiesuk/epb-register-api.git"
EPB_REGISTER_API_PATH="$(printf "%q" "$CODEBASE_PATH")"

EPB_FRONTEND_PATH=$EPB_FRONTEND_PATH \
EPB_AUTH_SERVER_PATH=$EPB_AUTH_SERVER_PATH \
EPB_REGISTER_API_PATH=$EPB_REGISTER_API_PATH \
generate_template

bash scripts/reset.sh

setup_hostsfile

setup_bash_profile
