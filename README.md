# README

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

## TODO

- [ ] add binding pry
- [ ] turn on confirmable
- [ ] enforce uniquness of username - or should it be nickname
- [ ] add binding.pry
- [ ] email template and emails
- [ ] an admin view
- [ ] we no longer have a flash message due to the redirects
- [ ] make SitePrism page model always accessible without new
- [ ] default capybara test_id to be data-testid
- [ ] abstract the image path
- [ ] better finders for identifying pages
- [ ] share to github
- [ ] share to twitter
- [ ] share to linkedIn

## DONE

- [x] profile page
- [x] better wait finders? like count ones for things like
```
expect(page).to have_content "Pair with me"
```
  - using `have_current_page` matcher as suggested by rubocop
