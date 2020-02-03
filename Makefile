.PHONY: setup
SHELL=/usr/bin/env bash

setup:
	@$(SHELL) scripts/setup.sh

reset:
	@source scripts/_functions.sh \
		&& reset_environment

pull:
	@$(SHELL) scripts/pull.sh
