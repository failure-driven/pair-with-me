# frozen_string_literal: true

module Pages
  class Admin < SitePrism::Page
    set_url Rails.application.routes.url_helpers.admin_root_path

    element :flash, ".flash"

    elements :destinations, ".navigation a"

    element :new_promotion, :css, "header a", text: "New promotion"
    element :demo_send, "[data-testid=demo-send]"

    element :submit, :css, "input[type=submit]"

    def navigate_to(nav_text)
      destinations.find { |destination| destination.text == nav_text }.click
    end

    # TODO: so similar to UserRegistration, should abstract out
    def submit!(model, **args)
      args.each do |key, value|
        finder = "#{model}_#{key}"
        if page.find("##{finder}")["type"] == "file"
          attach_file(finder, File.absolute_path(value))
        else
          fill_in finder, with: value
        end
      end
      submit.click
    end
  end
end
