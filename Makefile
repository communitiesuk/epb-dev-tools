.PHONY: setup reset pull sql-auth-server sql-register-api help
.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

install: ## install the development environment and tools
	@$(SHELL) scripts/install.sh

reset: ## reset the development environment
	@$(SHELL) scripts/reset.sh

rebuild: ## force rebuild all docker images
	@$(SHELL) scripts/rebuild.sh

start: ## start all docker images
	@$(SHELL) scripts/start.sh

stop: ## pause all docker images
	@$(SHELL) scripts/stop.sh

pull: ## git pull in all repositories
	@$(SHELL) scripts/pull.sh

sql: ## open an sql shell in the given application
	@if [[ -z "${APP}" ]]; then echo "Must give an application" && $(MAKE) help && exit 1; fi
	@$(SHELL) scripts/sql.sh

migrate: ## run migrations (epb migrate epb-auth-server)
	@if [[ -z "${APP}" ]]; then echo "Must give an application" && $(MAKE) help && exit 1; fi
	@docker-compose exec "${APP}" bash -c 'cd /app && bundle exec rake db:migrate'

rollback: ## rollback migrations (epb rollback epb-auth-server)
	@if [[ -z "${APP}" ]]; then echo "Must give an application" && $(MAKE) help && exit 1; fi
	@docker-compose exec "${APP}" bash -c 'cd /app && bundle exec rake db:rollback'

logs: ## tail container(s) logs (epb logs epb-auth-server)
	@docker-compose logs -f ${APP}

help:
	@echo "EPB Devtools Help"
	@echo
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
