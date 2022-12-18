# README

## TL;DR

install dependencies, _Note: there is a **debug install** section at the end_

```bash
make
asdf install # cannot run under make to install PostgreSQL

# requires a config/master.key also takes around 45 min to seed data
make install
```

run tests

```bash
make build
```

run the dev server - _it's easiset with `foreman` as you need to run the css comilation for TailwindCSS_

```bash
make start
```

Finally login via

```bash
open http://localhost:3030/users/sign_in?user[email]=5399968%2bselenasmall@users.noreply.github.com

# OR

open http://localhost:3030/users/sign_in?user[email]=278723%2bsaramic@users.noreply.github.com

# password is password
```

---

## Debug Install

### Problem running make build first time

There seems to be a first time problem in running the build with `make build`, make sure `make db-migrate` runs first

```bash
bin/rails db:environment:set RAILS_ENV=test
make db-migrate

make build
```

### Problem installing Ruby?

issues installing Ruby?, might need to uninstall the `capstone` disassembly framework

```bash
brew uninstall --ignore-dependencies capstone
asdf install
```

### Make sure your DB is running

The project is setup to run PostgreSQL on port `5442` so it does not interfere with other Postgreses running on your system

```bash
# once off
make pg-init # will create a postgres data and config in the ./tmp/ dir

# anytime the DB is not running, like after a restart
make pg-start

# incase you want to stop it
make pg-stop
```

### Not using ASDF

If you are not using `asdf` you can check if you have the prerequisite tools with

```bash
make check-tools
```

### Starting the dev server

The dev server requries running `bin/rails s` and also `yarn build:css` to make sure you have the TailwindCSS stylesheets so simplest to run `make start` which uses the `foreman` gem under the covers

```bash
make start

# OR

gem install foreman # should have been installed with make install
foreman start --procfile=Procfile.dev
```

Make file configures `foreman` to run on port `3030` so as not to conflict with other rails projects

```bash
open http://localhost:3030/
```

### Run pair-with.test using Puma-dev

run with puma-dev

```bash
# assuming puma-dev is installed
brew install puma-dev
puma-dev -install

# create a pair-with me file
cat > ~/.puma-dev/pair-with
3030

# run on specified port
PORT=3030 foreman start --procfile=Procfile.dev

# visit in browser
open http://pair-with.test/
open http://user-saramic.pair-with.test/
```

## Redis not running

Redis is required to run sidekiq for background jobs

```bash
brew install redis
brew services list # should be running

# alternatively start manually
redis-server --daemonize yes
```

### Seed data

seed data, should have been run as part of `make install` in the `bin/setup` step but in a nutshell

The following fetches the public repos for the provided user. Any calls to GitHub API are cached in `tmp/fetch_cache`. A copy of repositories is kept in `tmp/pair_repositories` this will get reasonably large.

```bash
bin/rails runner 'FindPairs.new.process(ARGV)' SelenaSmall
bin/rails runner 'FindPairs.new.process(ARGV)' saramic
bin/rails runner 'FindPairs.new.process(ARGV)' failure-driven
```

set an admin user, also part of seeds

```bash
bin/rails runner "User.find_by(username: ARGV).
  tap{|user| user.update!(
    user_actions: user.user_actions.merge(
      admin: { can_administer: true }))}" SelenaSmall
```

---

more info on work being done can be found in [PROJECT.md](PROJECT.md)
