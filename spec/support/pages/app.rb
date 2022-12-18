# frozen_string_literal: true

module Pages
  class App < SitePrism::Page
    set_url Rails.application.routes.url_helpers.root_path

    element :signin_with_github, "[type=submit][value=\"Sign in with GitHub\"]"
    element :admin, "a[data-testid=admin-link]"

    element :alert, "[data-testid=alert]"
    element :notice, "[data-testid=notice]"
  end
end
