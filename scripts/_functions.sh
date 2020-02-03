#!/usr/bin/env bash

clone_application() {
  HELP_TEXT=$1
  CLONE_URL=$2
  CLONE_DIR="$(get_parent_directory)/$(get_name_from_git_uri "$CLONE_URL")"

  printf "%s\n" "$HELP_TEXT"

  if [[ -z $(confirm "Clone to $CLONE_DIR?") ]]; then
    CODEBASE_PATH=""
  else
    CODEBASE_PATH="$CLONE_DIR"

    if [[ ! -d $CODEBASE_PATH ]]; then
      echo -e "Cloning into local directory $CODEBASE_PATH\n"
      git clone "$CLONE_URL" "$CLONE_DIR"
    else
      echo -e "Directory already exists, continuing\n"
    fi
  fi

  if [[ -z $CODEBASE_PATH ]]; then
    echo -e "\nCancelling setup\n"
    exit 1
  fi

  export CODEBASE_PATH=$CODEBASE_PATH
}

confirm() {
  HELP_TEXT=$1
  while true; do
    read -rp "$HELP_TEXT [y/N] " CONFIRMATION
    case $CONFIRMATION in
    [Yy]*)
      CONFIRMED=1
      break
      ;;
    *)
      break
      ;;
    esac
  done
  echo $CONFIRMED
}

join() {
  local IFS="$1"
  shift
  echo "$*"
}

get_name_from_git_uri() {
  CLONE_URL=$1
  IFS='/' read -ra CODE_DIR <<<"$CLONE_URL"
  CODE_DIR="${CODE_DIR[1]}"
  echo "${CODE_DIR/.git/}"
}

get_parent_directory() {
  IFS='/' read -ra CODE_DIR <<<"$PWD"
  unset 'CODE_DIR[${#CODE_DIR[@]}-1]'
  # shellcheck disable=SC2068
  echo "/$(join / ${CODE_DIR[@]})"
}

reset_environment() {
  if [[ -n $(confirm "Do you want to reset and configure the dev environment?") ]]; then
    # Ensure images are built
    docker-compose down
    docker-compose rm -f
    docker-compose build
    docker-compose up -d

    # Setup db and other essentials
    docker-compose exec epb-auth-server bash -c 'cd /app && make db-setup'
    docker-compose exec epb-auth-server-db bash -c "psql --username epb_auth -d epb_auth -c \"INSERT INTO clients (id, name, secret) VALUES ('6f61579e-e829-47d7-aef5-7d36ad068bee', 'epb_frontend', 'test-client-secret');\""

    docker-compose exec epb-register-api bash -c 'cd /app && make setup-db'
    docker-compose exec epb-register-api bash -c 'cd /app && bundle exec rake import_postcode'
    docker-compose exec epb-register-api bash -c 'cd /app && bundle exec rake import_postcode_outcode'
    docker-compose exec epb-register-api bash -c 'cd /app && bundle exec rake generate_schemes'
    docker-compose exec epb-register-api bash -c 'cd /app && bundle exec rake generate_assessor'
  fi
}

generate_template() {
  rm -r docker-compose.yml 2>/dev/null
  cat <<EOF > docker-compose.yml
version: '3.7'
services:
  epb-frontend:
    build:
      context: ${EPB_FRONTEND_PATH}
      dockerfile: ${PWD}/epbFrontend.Dockerfile
    entrypoint: bash -c 'cd /app && bundle exec rackup -p 80 -o 0.0.0.0'
    environment:
      EPB_API_URL: http://epb-register-api
      EPB_AUTH_CLIENT_ID: 6f61579e-e829-47d7-aef5-7d36ad068bee
      EPB_AUTH_CLIENT_SECRET: test-client-secret
      EPB_AUTH_SERVER: http://epb-auth-server
      EPB_UNLEASH_URI: https://google.com
      JWT_ISSUER: epb-auth-server
      JWT_SECRET: test-jwt-secret
      STAGE: production
    links:
      - epb-auth-server
      - epb-register-api
    ports:
      - "8080:80"
    volumes:
      - ${EPB_FRONTEND_PATH}:/app

  epb-auth-server:
    build:
      context: ${EPB_AUTH_SERVER_PATH}
      dockerfile: ${PWD}/epbAuthServer.Dockerfile
    entrypoint: bash -c 'cd /app && bundle exec rackup -p 80 -o 0.0.0.0'
    environment:
      DATABASE_URL: postgresql://epb_auth:superSecret30CharacterPassword@epb-auth-server-db/epb_auth
      JWT_ISSUER: epb-auth-server
      JWT_SECRET: test-jwt-secret
    links:
      - epb-auth-server-db
    volumes:
      - ${EPB_AUTH_SERVER_PATH}:/app

  epb-auth-server-db:
    build:
      context: ${PWD}/
      dockerfile: ${PWD}/epbDatabase.Dockerfile
    environment:
      POSTGRES_PASSWORD: superSecret30CharacterPassword
      POSTGRES_USER: epb_auth

  epb-register-api:
    build:
      context: ${EPB_REGISTER_API_PATH}
      dockerfile: ${PWD}/epbRegisterApi.Dockerfile
    entrypoint: bash -c 'cd /app && bundle exec rackup -p 80 -o 0.0.0.0'
    environment:
      DATABASE_URL: postgresql://epb_register:superSecret30CharacterPassword@epb-register-api-db/epb_register
      EPB_UNLEASH_URI: https://google.com
      JWT_ISSUER: epb-auth-server
      JWT_SECRET: test-jwt-secret
      STAGE: production
    links:
      - epb-register-api-db
    volumes:
      - ${EPB_REGISTER_API_PATH}:/app

  epb-register-api-db:
    build:
      context: ${PWD}/
      dockerfile: ${PWD}/epbDatabase.Dockerfile
    environment:
      POSTGRES_PASSWORD: superSecret30CharacterPassword
      POSTGRES_USER: epb_register

EOF
}
