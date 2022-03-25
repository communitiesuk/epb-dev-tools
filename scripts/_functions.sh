#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pull_application() {
  CLONE_URL=$1
  CLONE_DIR="$(get_parent_directory)/$(get_name_from_git_uri "$CLONE_URL")"

  echo -e "Checking directory $CLONE_DIR\n"

  if [[ -d $CLONE_DIR ]]; then
    echo -e "Pulling git repo at $CLONE_DIR\n"
    ORIGIN_DIR=$PWD

    cd "$CLONE_DIR" || exit 1
    git pull
    cd "$ORIGIN_DIR" || exit 1
  else
    echo -e "Cloning git repo at $CLONE_DIR\n"
    git clone "$CLONE_URL" "$CLONE_DIR"
  fi
}

clone_application() {
  HELP_TEXT=$1
  CLONE_URL=$2
  CLONE_DIR="$(get_parent_directory)/$(get_name_from_git_uri "$CLONE_URL")"

  printf "%s\n" "$HELP_TEXT"

  CODEBASE_PATH="$CLONE_DIR"

  if [[ ! -d $CODEBASE_PATH ]]; then
    echo -e "Cloning into local directory $CODEBASE_PATH\n"
    git clone "$CLONE_URL" "$CLONE_DIR"
  else
    echo -e "Directory $CODEBASE_PATH already exists, continuing\n"
  fi

  if [[ -z $CODEBASE_PATH ]]; then
    echo -e "\nCancelling setup\n"
    exit 1
  fi

  export CODEBASE_PATH=$CODEBASE_PATH
}

confirm() {
  HELP_TEXT=$1

  if [[ "$OVERRIDE_CONFIRM" == "true" ]]; then
    echo "Overriding confirmation for $HELP_TEXT"
    CONFIRMED=1
    echo $CONFIRMED

  else
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

  fi
}

join() {
  local IFS="$1"
  shift
  echo "$*"
}

get_name_from_git_uri() {
  CLONE_URL=$1
  IFS='/' read -ra CODE_DIR <<<"$CLONE_URL"
  CODE_DIR="${CODE_DIR[${#CODE_DIR[@]}-1]}"
  echo "${CODE_DIR/.git/}"
}

get_parent_directory() {
  IFS='/' read -ra CODE_DIR <<<"$PWD"
  unset 'CODE_DIR[${#CODE_DIR[@]}-1]'
  # shellcheck disable=SC2068
  echo "/$(join / ${CODE_DIR[@]})"
}

generate_template() {
  rm -r docker-compose.yml 2>/dev/null
  cat <<EOF > docker-compose.yml
version: '3.7'
services:
  epb-proxy:
    build:
      context: ${PWD}/
      dockerfile: ${PWD}/nginxReverseProxy.Dockerfile
    links:
      - epb-auth-server
      - epb-register-api
      - epb-frontend
      - epb-feature-flag
    ports:
      - "80:80"
    volumes:
      - ${PWD}/http_files:/var/www/http_files

  epb-frontend:
    build:
      context: ${EPB_FRONTEND_PATH}
      dockerfile: ${PWD}/sinatra.Dockerfile
    environment:
      EPB_API_URL: http://epb-register-api
      EPB_AUTH_CLIENT_ID: 6f61579e-e829-47d7-aef5-7d36ad068bee
      EPB_AUTH_CLIENT_SECRET: test-client-secret
      EPB_AUTH_SERVER: http://epb-auth-server/auth
      EPB_UNLEASH_URI: http://epb-feature-flag/api
      JWT_ISSUER: epb-auth-server
      JWT_SECRET: test-jwt-secret
      STAGE: development
    links:
      - epb-auth-server
      - epb-feature-flag
      - epb-register-api
    volumes:
      - ${EPB_FRONTEND_PATH}:/app

  epb-auth-server:
    build:
      context: ${EPB_AUTH_SERVER_PATH}
      dockerfile: ${PWD}/sinatra.Dockerfile
    environment:
      DATABASE_URL: postgresql://epb:superSecret30CharacterPassword@epb-auth-server-db/epb
      JWT_ISSUER: epb-auth-server
      JWT_SECRET: test-jwt-secret
      URL_PREFIX: /auth
      RACK_ENV: development
      STAGE: development
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
      POSTGRES_USER: epb
    volumes:
      - auth-server:/var/lib/postgresql/data

  epb-register-api:
    build:
      context: ${EPB_REGISTER_API_PATH}
      dockerfile: ${PWD}/sinatra.Dockerfile
    environment:
      DATABASE_URL: postgresql://epb:superSecret30CharacterPassword@epb-register-api-db/epb
      EPB_UNLEASH_URI: http://epb-feature-flag/api
      EPB_DATA_WAREHOUSE_QUEUES_URI: redis://epb-data-warehouse-queues
      JWT_ISSUER: epb-auth-server
      JWT_SECRET: test-jwt-secret
      STAGE: development
    links:
      - epb-feature-flag
      - epb-register-api-db
      - epb-data-warehouse-queues
    volumes:
      - ${EPB_REGISTER_API_PATH}:/app

  epb-register-api-db:
    build:
      context: ${PWD}/
      dockerfile: ${PWD}/epbDatabase.Dockerfile
    environment:
      POSTGRES_PASSWORD: superSecret30CharacterPassword
      POSTGRES_USER: epb
    volumes:
      - register-api:/var/lib/postgresql/data

  epb-data-warehouse-queues:
    image: redis

  epb-feature-flag:
    build:
      context: ${PWD}/
      dockerfile: ${PWD}/unleash.Dockerfile
    environment:
      DATABASE_URL: postgresql://unleashed:superSecret30CharacterPassword@epb-feature-flag-db/unleashed
      DATABASE_SSL: "false"
      HTTP_HOST: 0.0.0.0
      HTTP_PORT: 80
    links:
      - epb-feature-flag-db
    command: >
      sh -c "
        while ! nc -z epb-feature-flag-db 5432; do
          echo 'Postgres is unavailable - trying again in 1s...'
          sleep 1
        done
        sleep 1
        echo 'Starting Unleash...'
        yarn run start"

  epb-feature-flag-db:
    build:
      context: ${PWD}/
      dockerfile: ${PWD}/epbDatabase.Dockerfile
    environment:
      POSTGRES_PASSWORD: superSecret30CharacterPassword
      POSTGRES_USER: unleashed
    volumes:
      - feature-flag:/var/lib/postgresql/data

  epb-data-warehouse:
    build:
      context: ${EPB_DATA_WAREHOUSE_PATH}
      dockerfile: ${PWD}/dataWarehouse.Dockerfile
    environment:
      DATABASE_URL: postgresql://epb:SecretWarehousePassword@epb-data-warehouse-db/epb?pool=50
      EPB_API_URL: http://epb-register-api
      EPB_QUEUES_URI: redis://epb-data-warehouse-queues
      EPB_AUTH_CLIENT_ID: 5e7b7607-971b-45a4-9155-cb4f6ea7e9f5
      EPB_AUTH_CLIENT_SECRET: data-warehouse-secret
      EPB_AUTH_SERVER: http://epb-auth-server/auth
      EPB_UNLEASH_URI: http://epb-feature-flag/api
      JWT_ISSUER: epb-auth-server
      JWT_SECRET: test-jwt-secret
      STAGE: development
    links:
      - epb-feature-flag
      - epb-data-warehouse-db
      - epb-data-warehouse-queues
    volumes:
      - ${EPB_DATA_WAREHOUSE_PATH}:/app

  epb-data-warehouse-db:
    build:
      context: ${PWD}/
      dockerfile: ${PWD}/epbDatabase.Dockerfile
    environment:
      POSTGRES_PASSWORD: SecretWarehousePassword
      POSTGRES_USER: epb
    volumes:
      - data-warehouse:/var/lib/postgresql/data



volumes:
  feature-flag:
  register-api:
  auth-server:
  data-warehouse:

EOF
}

setup_hostsfile() {
  HOSTS_LINE="127.0.0.1 getting-new-energy-certificate.epb-frontend find-energy-certificate.epb-frontend epb-frontend epb-register-api epb-auth-server epb-feature-flag"

  if grep -q "$HOSTS_LINE" "/etc/hosts"; then
    echo "Hostsfile configuration already there"
  else
    echo "Injecting hostsfile configuration"
    echo "$HOSTS_LINE" | sudo tee -a /etc/hosts
  fi
}

setup_bash_profile() {
  ALIAS_INFO="alias epb=\"$DIR/../epb\""

  if [[ -f "$HOME/.zshrc" ]]; then
    if [[ -n $(confirm "Add epb to profile at ~/.zshrc?") ]]; then
      if grep -q "$ALIAS_INFO" "$HOME/.zshrc"; then
        # shellcheck disable=SC2088
        echo "~/.zshrc already has the line $ALIAS_INFO"
      else
        echo "Injecting into ~/.zshrc, run source ~/.zshrc to use the command"
        echo "$ALIAS_INFO" | tee -a ~/.zshrc
      fi
    fi
  fi

  if [[ -f "$HOME/.bash_profile" ]]; then
    if [[ -n $(confirm "Add epb to profile at ~/.bash_profile?") ]]; then
      if grep -q "$ALIAS_INFO" "$HOME/.bash_profile"; then
        # shellcheck disable=SC2088
        echo "~/.bash_profile already has the line $ALIAS_INFO"
      else
        echo "Injecting into ~/.bash_profile, run source ~/.bash_profile to use the command"
        echo "$ALIAS_INFO" | tee -a ~/.bash_profile
      fi
    fi
  fi

}

until_accepting_connections() {
  CONTAINER_NAME=$1
  until docker run --rm --network epb-dev-tools_default --link "$CONTAINER_NAME:pg" postgres:11 pg_isready -U postgres -h pg; do sleep 1; done
}
