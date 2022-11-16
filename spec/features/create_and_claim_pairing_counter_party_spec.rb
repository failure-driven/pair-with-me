# frozen_string_literal: true

require "rails_helper"

feature "Create and claim pairing counter party", :js do
  scenario "Manual process creates pairing counter parites which are later claimed" do # rubocop:disable RSpec/NoExpectationExample
    Given "Michael has a pairing history with a number of users including Selena"
    When "Michael's profile is viewed"
    Then "Selena can be seen as an un-verified pair"
    And "her profile can be viewed as un-claimed"
    When "Selena logs in via GitHub"
    Then "she is asked to claim her account"
    And "verify the pairing with Michael"
  end
end
