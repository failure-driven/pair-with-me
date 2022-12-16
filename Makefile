.DEFAULT_GOAL := usage

# user and repo
USER        = $$(whoami)
CURRENT_DIR = $(notdir $(shell pwd))

# terminal colours
RED     = \033[0;31m
GREEN   = \033[0;32m
YELLOW  = \033[0;33m
NC      = \033[0m

.PHONY: check-tools
check-tools:
	bin/makefile/check-tools

.PHONY: asdf-install
asdf-install:
	asdf install

tmp/fetch_cache:
	mkdir tmp/fetch_cache

.PHONY: install
install: asdf-install pg-init pg-start check-tools tmp/fetch_cache
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

.PHONY: db-migrate
db-migrate:
	bundle exec rails db:create db:migrate
	bundle exec rails db:drop db:create db:migrate RAILS_ENV=test

.PHONY: build
build: db-migrate rubocop rspec

.PHONY: check-foreman
check-foreman: check-foreman
	gem list -i "foreman" || gem install foreman

.PHONY: start
start: check-foreman
	PORT=3030 foreman start --procfile=Procfile.dev

.PHONY: deploy
deploy:
	RAILS_MASTER_KEY=`cat config/master.key` \
		HEROKU_APP_NAME=pairwithme \
		HEROKU_DOMAIN=pair-with.me \
		bin/makefile/heroku-create

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
	@echo "${YELLOW}asdf install${NC}      asdf needs to be run outside of make"
	@echo "${YELLOW}make install${NC}      install all the things"
	@echo
	@echo "${YELLOW}make build${NC}        run the build"
	@echo "${YELLOW}make start${NC}        start the server"
	@echo
	@echo "Development"
	@echo
	@echo "${YELLOW}make rubocop${NC}      rubocop"
	@echo "${YELLOW}make rubocop-fix${NC}  rubocop fix"
	@echo "${YELLOW}make rspec${NC}        run rspec tests"
	@echo "${YELLOW}make db-migrate${NC}   run upto date migrations"
	@echo "${YELLOW}make pg-init${NC}      one off initialize db in tmp/postgres port 5442"
	@echo "${YELLOW}make pg-start${NC}     start the db on port 5442"
	@echo "${YELLOW}make pg-stop${NC}      stop the db on port 5442"
	@echo
	@echo "Deployment"
	@echo
	@echo "${YELLOW}make deploy${NC}       deploy to heroku"
	@echo
