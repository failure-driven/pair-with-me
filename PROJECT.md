# PROJECT

This file is split into

- the **Aim** of what we want to achieve
- core **Flows** that make up the aim
- a list of **TODO**'s
- and a list of **Done** things

## Aim

**pair-with.me** is the only place that will calculate your **"Pair Programming"** reputation, allow you to share it on various forums (_like LinkedIn and your GitHub landing page_) and revist all your best past pairings or find new people to pair with and if you are lucky end up on our https://www.twitch.tv/failure_driven channel!
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

## TODO

- [ ] **feature** generate promotional emails
  - [x] model to store promotions
  - [x] ability to send demo email
  - [ ] ability to send mail merge
  - [x] local dev email viewing
  - [ ] better email template - https://github.com/leemunroe/responsive-html-email-template
- [ ] **bug** fix flakey test: seems not to click the **sign out** button at all so
  does not transition to the `sign in` root page
```bash
repeat 10 { bundle exec rspec ./spec/features/user_signup_spec.rb:76 }
```
- [ ] **feature** turn on confirmable
- [ ] **tools** add binding.pry and pry debugging to do `next` and `step`
- [ ] **bug** redirect https://pair-with.me/admin to a login page that works
- [ ] **tools** make SitePrism page model always accessible without new
- [ ] **tools** default capybara test_id to be data-testid
- [ ] **bug** abstract the image path, especially for testing
- [ ] **bug** better finders for identifying pages
- [ ] **feature** share to github
- [ ] **feature** share to twitter
- [ ] **feature** share to linkedIn
- [ ] **tools** github signin in development?
- [ ] **feature** analyse github repos for co-authored-by
- [ ] **tools** github actions build
- [ ] **bug** fix first bet email not to have `}` at the end

## Done

- [x] **tools** make db-migrate
- [x] **tools** add bin/rspec binstub with `bundle binstubs rspec-core`
- [X] **docs** reliable new developer onboarding experience
- [X] **feature** an admin view
- [x] **bug** enforce uniquness of username - or should it be nickname
- [x] **bug** we no longer have a flash message due to the redirects
  - we seem to in production (ie using Github and not just fake email signin)
- [x] **feature** profile page
- [x] **bug** better wait finders? like count ones for things like
```
expect(page).to have_content "Pair with me"
```
  - using `have_current_page` matcher as suggested by rubocop
