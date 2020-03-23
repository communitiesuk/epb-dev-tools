#!/usr/bin/env bash

source scripts/_functions.sh

echo "OVERRIDE SET TO $OVERRIDE_CONFIRM"

if [[ -z $(confirm "Do you want to rebuild the dev environment?") ]]; then
  echo "Bailing from rebuild"
else
  # Ensure images are built
  docker-compose down
  docker-compose rm -f
  docker-compose build
  docker-compose up -d
fi
