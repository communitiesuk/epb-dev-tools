#!/usr/bin/env bash

source scripts/_functions.sh

if [[ -n $(confirm "Do you want to start the dev environment?") ]]; then
  cd "$DIR/.." && docker-compose up -d
fi
