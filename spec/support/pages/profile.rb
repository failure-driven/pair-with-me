# frozen_string_literal: true

class Profile < SitePrism::Page
  set_url Rails.application.routes.url_helpers.show_profile_path(:username)

  element :profile_name, "[data-testid=profile-name]"
  element :sign_out, "[data-testid=sign-out]"
end
