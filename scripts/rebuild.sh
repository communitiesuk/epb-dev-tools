#!/usr/bin/env bash

source scripts/_functions.sh

if [[ -n $(confirm "Do you want to rebuild the dev environment?") ]]; then
  # Ensure images are built
  docker-compose down
  docker-compose rm -f
  docker-compose build
  docker-compose up -d
fi
