.PHONY: reset pull sql-auth-server sql-register-api help
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

redis: ## open a redis-cli session on the given container
	@if [[ -z "${APP}" ]]; then echo "Must give a container containing a Redis server" && $(MAKE) help && exit 1; fi
	@$(SHELL) scripts/redis.sh

migrate: ## run migrations (epb migrate epb-auth-server)
	@if [[ -z "${APP}" ]]; then echo "Must give an application" && $(MAKE) help && exit 1; fi
	@docker compose exec "${APP}" bash -c 'cd /app && bundle exec rake db:migrate'

rollback: ## rollback migrations (epb rollback epb-auth-server)
	@if [[ -z "${APP}" ]]; then echo "Must give an application" && $(MAKE) help && exit 1; fi
	@docker compose exec "${APP}" bash -c 'cd /app && bundle exec rake db:rollback'

logs: ## tail container(s) logs (epb logs epb-auth-server)
	@docker compose logs -f ${APP}

help:
	@echo "EPB Devtools Help"
	@echo
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

security-scan:
	@echo "Running ZAP scan"
	@$(SHELL) scripts/security_scan.sh

lodge-assessments: ## run rake to save xml fixtures to docker db
		@docker compose exec -T epb-register-api bash -c 'cd /app && bundle exec rake dev_data:lodge_dev_assessments'

load-local-data:
		@docker compose up  -d --force-recreate --build epb-register-api-db
		@docker compose up  -d --force-recreate --build epb-data-warehouse-db
		@docker compose exec -T epb-data-warehouse bash -c 'cd /app && bundle exec rake db:migrate'
		@docker compose exec -T epb-register-api bash -c 'cd /app && RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 make seed-local-db'

load-service-stats-data:
	@docker compose up  -d --force-recreate --build epb-register-api-db
	@docker compose exec -T epb-register-api bash -c 'cd /app && RACK_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 make setup-db && rake dev_data:generate_fake_stats'
	@docker compose up  -d --force-recreate --build epb-data-warehouse-db
	@docker compose exec -T epb-data-warehouse bash -c 'cd /app && bundle exec rake db:migrate && make seed-stats-data'

