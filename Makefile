RAILS_ENV ?= development
COMPOSE_PROJECT_NAME := $(shell basename $(shell pwd))
COMPOSE_COMMAND := docker-compose


dev:
	@$$($(MAKE) --no-print-directory envs) && hivemind Procfile.dev
.PHONY: dev

guard:
	@$$($(MAKE) --no-print-directory envs) && bundle exec guard --plugin RSpec
.PHONY: guard

infra-up:
	${COMPOSE_COMMAND} up -d
	@$$($(MAKE) --no-print-directory envs) && bin/spring stop
	@$$($(MAKE) --no-print-directory envs) && rails db:migrate || rails db:setup
.PHONY: infra-up

infra-down:
	${COMPOSE_COMMAND} down
	@bundle exec spring stop
.PHONY: infra-down

envs:
	$(eval DB_CONTAINER := $(shell docker ps -q --filter 'name=${COMPOSE_PROJECT_NAME}_db_*'))
	$(eval DB_PORT := $(shell docker port ${DB_CONTAINER} | cut -d ':' -f 2))
	@echo "export DB_PORT=${DB_PORT}"
.PHONY: envs

rails-console:
	@$$($(MAKE) --no-print-directory envs) && rails console
.PHONY: rails-console

db-console:
	@$$($(MAKE) --no-print-directory envs) && rails dbconsole
.PHONY: db-console
