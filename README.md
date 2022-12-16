# README

## TL;DR

```
bin/setup
make
make build

gem install foreman
foreman start --procfile=Procfile.dev
```

## Original

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Flows

- [ ] clean registration
  - [x] register with github
  > User comes along and registers using their github credentials. They get redirected to their profile page and are informed we are curnching away at working out their pairing status based on their public repositories. They are also shown how to add a `Co-authored-by:` tag to their commits. And they get an email. Once processing is finished they are encouraged to share their profile on Twitter/linkedIn and GitHub user landing page.
- [ ] pairing counter party
  - [ ] generate counter party for pairing
  - [ ] verification status on pairing
  > from the analysis of another codebase your GitHub user handle is discovered and added in a "counter party" mode. Pairings between this counter party are there but not "verified"
- [ ] claim your registration
  - [ ] user attempts to log in when their username is already counter partied
  > you are informed about a pairing session or simply come and join the platform and are shown you already have a pairing history. You are able to "claim" your account and verify the pairings
- [ ] networked registration
  > post bringing in your pairing history you are given the option to send an invitation to you pairing "counter parties". The email allows you to sign up and claim your pairing status
- [ ] pairing encouragment
  > user is notified of recent pairings on the platform. There is a match making service for remote pairing sessions of the "right" level in the right "technology". User pairs have a freshness rating. A goal setting plan can be put in place to keep your pairing experiences fresh.
- [ ] alpha program
  - [ ] email sending ability
  > users are emailed with regular updates what is new and planned for the platform

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

## TODO

- [ ] bug fix flakey test: seems not to click the **sign out** button at all so
  does not transition to the `sign in` root page
```bash
repeat 10 { bundle exec rspec ./spec/features/user_signup_spec.rb:76 }
```
- [ ] add binding pry
- [ ] add bin/rspec bin stub
- [ ] make db-migrate
- [ ] turn on confirmable
- [ ] add binding.pry
- [ ] email template and emails
- [ ] redirect https://pair-with.me/admin to a login page that works
- [ ] make SitePrism page model always accessible without new
- [ ] default capybara test_id to be data-testid
- [ ] abstract the image path, especially for testing
- [ ] better finders for identifying pages
- [ ] share to github
- [ ] share to twitter
- [ ] share to linkedIn
- [ ] github signin in development?
- [ ] analyse github repos for co-authored-by
- [ ] github actions build
- [ ] fix first bet email not to have `}` at the end

## DONE

- [X] an admin view
- [x] enforce uniquness of username - or should it be nickname
- [x] we no longer have a flash message due to the redirects
  - we seem to in production (ie using Github and not just fake email signin)
- [x] profile page
- [x] better wait finders? like count ones for things like
```
expect(page).to have_content "Pair with me"
```
  - using `have_current_page` matcher as suggested by rubocop
