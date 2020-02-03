#!/usr/bin/env bash

source scripts/_functions.sh

echo -e "\nSetting up epb dev tools\n"

clone_application "EPB Frontend" "git@github.com:communitiesuk/epb-frontend.git"
EPB_FRONTEND_PATH="$(printf "%q" "$CODEBASE_PATH")"

clone_application "EPB Auth Server" "git@github.com:communitiesuk/epb-auth-server.git"
EPB_AUTH_SERVER_PATH="$(printf "%q" "$CODEBASE_PATH")"

clone_application "EPB Register API" "git@github.com:communitiesuk/epb-register-api.git"
EPB_REGISTER_API_PATH="$(printf "%q" "$CODEBASE_PATH")"

rm -r docker-compose.yml 2>/dev/null

cat <<EOF > docker-compose.yml
version: '3.7'
services:
  epb-frontend:
    build:
      context: ${EPB_FRONTEND_PATH}
      dockerfile: ${PWD}/epbFrontend.Dockerfile
    entrypoint: "bash -c 'cd /app && bundle exec rackup -p 80 -o 0.0.0.0'"
    environment:
      EPB_API_URL: "http://epb-register-api"
      EPB_AUTH_CLIENT_ID: "6f61579e-e829-47d7-aef5-7d36ad068bee"
      EPB_AUTH_CLIENT_SECRET: "test-client-secret"
      EPB_AUTH_SERVER: "http://epb-auth-server"
      EPB_UNLEASH_URI: "https://google.com"
      JWT_ISSUER: "epb-auth-server"
      JWT_SECRET: "test-jwt-secret"
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
    entrypoint: "bash -c 'cd /app && bundle exec rackup -p 80 -o 0.0.0.0'"
    environment:
      DATABASE_URL: "postgresql://epb_auth:superSecret30CharacterPassword@epb-auth-server-db/epb_auth"
      JWT_ISSUER: "epb-auth-server"
      JWT_SECRET: "test-jwt-secret"
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
    entrypoint: "bash -c 'cd /app && bundle exec rackup -p 80 -o 0.0.0.0'"
    environment:
      DATABASE_URL: "postgresql://epb_register:superSecret30CharacterPassword@epb-register-api-db/epb_register"
      EPB_UNLEASH_URI: "https://google.com"
      JWT_ISSUER: "epb-auth-server"
      JWT_SECRET: "test-jwt-secret"
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

if [[ -n $(confirm "Do you want to start and configure the dev environment?") ]]; then
  # Ensure images are built
  docker-compose down
  docker-compose rm -f
  docker-compose build
  docker-compose up -d

  # Setup db and other essentials
  docker-compose exec epb-auth-server bash -c 'cd /app && make db-setup'
  docker-compose exec epb-register-api bash -c 'cd /app && make setup-db'
fi

