# frozen_string_literal: true

class App < SitePrism::Page
  # set_url Rails.application.routes.url_helpers.root_path
  set_url "/users/sign_up" # TODO: replace with registration path helper

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
