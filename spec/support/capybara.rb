# frozen_string_literal: true

require "capybara/rspec"
require "capybara/rails"
require "capybara-inline-screenshot/rspec"

# as per https://github.com/teamcapybara/capybara/issues/2666
# to get around
# ruby 3.2 related
#   ArgumentError: wrong number of arguments (given 2, expected 0..1)
Selenium::WebDriver.logger.output = false

Capybara.javascript_driver = :selenium_chrome

Capybara.register_driver :selenium_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  if ENV.fetch("GITHUB_ACTIONS", nil) == "true"
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
  end

  args = {browser: :chrome}
  args[:options] = options if options
  Capybara::Selenium::Driver.new(
    app,
    **args,
  )
end

Capybara::Screenshot.register_driver(:selenium_chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.add_selector(:qa) do
  css { |name| %([data-testid="#{name}"]) }
end
