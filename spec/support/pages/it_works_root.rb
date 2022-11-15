# frozen_string_literal: true

class ItWorksRoot < SitePrism::Page
  set_url Rails.application.routes.url_helpers.test_root_rails_path

  element :rails_version, "ul li", text: "Rails version"
  element :ruby_version, "ul li", text: "Ruby version"
end
