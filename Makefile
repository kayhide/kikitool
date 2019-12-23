RAILS_ENV ?= development
COMPOSE_PROJECT_NAME := $(shell basename $(shell pwd))
COMPOSE_COMMAND := docker-compose


dev:
	@hivemind $${PORT:+--port $$PORT} --port-step 1 Procfile.dev
.PHONY: dev

guard:
	@bin/bundle exec guard --plugin RSpec
.PHONY: guard

provision:
	${COMPOSE_COMMAND} up -d
	@bin/spring stop
	@$$($(MAKE) --no-print-directory envs) \
	&& (bin/rails db:migrate 2> /dev/null) || bin/rails db:setup
.PHONY: provision

unprovision:
	${COMPOSE_COMMAND} down
	@bin/spring stop
.PHONY: unprovision

envs: DB_PORT := $(shell docker-compose port db 5432 | cut -d ':' -f 2)
envs: REDIS_PORT := $(shell docker-compose port redis 6379 | cut -d ':' -f 2)
envs:
	@echo "export DB_PORT=${DB_PORT}"
	@echo "export REDIS_PORT=${REDIS_PORT}"
.PHONY: envs
