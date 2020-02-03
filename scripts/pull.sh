#!/usr/bin/env bash

source scripts/_functions.sh

echo -e "\nUpdating epb dev tools environment\n"

echo "EPB Frontend"
pull_application "git@github.com:communitiesuk/epb-frontend.git"

echo "EPB Auth Server"
pull_application "git@github.com:communitiesuk/epb-auth-server.git"

echo "EPB Register API"
pull_application "git@github.com:communitiesuk/epb-register-api.git"
