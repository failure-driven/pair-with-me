# README

## TL;DR

```
bin/setup
make
make build

gem install foreman
foreman start --procfile=Procfile.dev
```

## Setup

test and development database using port 5442 running in `tmp/` folder

```bash
# once off initialize database
make db-init

# start it, or restart after computer reboot
make db-start

# stop it
make db-stop
```

run with puma-dev

```bash
# assuming puma-dev is installed

# create a pair-with me file
cat > ~/.puma-dev/pair-with
3030

# run on specified port
PORT=3030 foreman start --procfile=Procfile.dev

# visit in browser
open http://pair-with.test/
open http://user-b.pair-with.test/
```

seed data

```bash
bin/rails r 'FindPairs.new.process(ARGV.join())' SelenaSmall
bin/rails r 'FindPairs.new.process(ARGV.join())' saramic
bin/rails r 'FindPairs.new.process(ARGV.join())' failure-driven
```

set an admin user

```bash
bin/rails runner "User.find_by(username: ARGV).
  tap{|user| user.update!(
    user_actions: user.user_actions.merge(
      admin: { can_administer: true }))}" SelenaSmall
```

---

more info on work being done can be found in [PROJECT.md](PROJECT.md)

