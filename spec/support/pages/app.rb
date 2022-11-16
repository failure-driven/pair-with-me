# frozen_string_literal: true

class App < SitePrism::Page
  set_url Rails.application.routes.url_helpers.new_user_registration_path

  element :submit, :css, "input[type=submit]"

  def submit!(**args)
    args.each do |key, value|
      if page.find("##{key}")["type"] == "file"
        attach_file(key, File.absolute_path(value))
      else
        fill_in key, with: value
      end
    end
    submit.click
  end
end
