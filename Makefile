.DEFAULT_GOAL := usage

# user and repo
USER        = $$(whoami)
CURRENT_DIR = $(notdir $(shell pwd))

# terminal colours
RED     = \033[0;31m
GREEN   = \033[0;32m
YELLOW  = \033[0;33m
NC      = \033[0m

.PHONY: install
install:
	asdf install
	bin/setup

.PHONY: rubocop-fix
rubocop-fix:
	bundle exec rubocop -A

.PHONY: rubocop
rubocop:
	bundle exec rubocop

.PHONY: rspec
rspec:
	bundle exec rspec

.PHONY: build
build: rubocop rspec

.PHONY: pg-init
pg-init:
	PGPORT=5442 asdf exec initdb tmp/postgres -E utf8 || echo "postgres already initialised"

.PHONY: pg-start
pg-start:
	PGPORT=5442 asdf exec pg_ctl -D tmp/postgres -l tmp/postgres/logfile start || echo "pg was probably running"

.PHONY: pg-stop
pg-stop:
	PGPORT=5442 asdf exec pg_ctl -D tmp/postgres stop -s -m fast || echo "postgres already stopped"

.PHONY: usage
usage:
	@echo
	@echo "Hi ${GREEN}${USER}!${NC} Welcome to ${RED}${CURRENT_DIR}${NC}"
	@echo
	@echo "Getting started"
	@echo
	@echo "${YELLOW}make${NC}              this menu"
	@echo "${YELLOW}make install${NC}      install all the things"
	@echo "${YELLOW}make build${NC}        run the build"
	@echo
	@echo "Development"
	@echo
	@echo "${YELLOW}make rubocop${NC}      rubocop"
	@echo "${YELLOW}make rubocop-fix${NC}  rubocop fix"
	@echo "${YELLOW}make rspec${NC}        run rspec tests"
	@echo "${YELLOW}make pg-init${NC}      one off initialize db in tmp/postgres port 5442"
	@echo "${YELLOW}make pg-start${NC}     start the db on port 5442"
	@echo "${YELLOW}make pg-stop${NC}      stop the db on port 5442"
	@echo
