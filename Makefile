.PHONY: setup reset pull sql-auth-server sql-register-api
.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

setup: ## do an initial setup and reset of the dev environment
	@$(SHELL) scripts/setup.sh

reset: ## reset the development environment
	@source scripts/_functions.sh \
		&& reset_environment

pull: ## git pull in all repositories
	@$(SHELL) scripts/pull.sh

sql-auth-server: ## open a psql shell in the auth server db
	@$(SHELL) scripts/psql-connect.sh "epb-auth-server" "epb_auth"

sql-register-api: ## open a psql shell in the register api db
	@$(SHELL) scripts/psql-connect.sh "epb-register-api" "epb_register"

logs: ## tail logs from all containers
	@docker-compose logs -f

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
