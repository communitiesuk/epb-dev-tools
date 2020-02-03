.PHONY: setup reset pull sql-auth-server sql-register-api
SHELL=/usr/bin/env bash

setup:
	@$(SHELL) scripts/setup.sh

reset:
	@source scripts/_functions.sh \
		&& reset_environment

pull:
	@$(SHELL) scripts/pull.sh

sql-auth-server:
	@$(SHELL) scripts/psql-connect.sh "epb-auth-server" "epb_auth"

sql-register-api:
	@$(SHELL) scripts/psql-connect.sh "epb-register-api" "epb_register"
