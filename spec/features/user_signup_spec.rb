# frozen_string_literal: true

require "rails_helper"

feature "User signup", :js do
  let(:app) { App.new }

  scenario "User signs up successfully" do
    When "Selena signs up with a valid username" do
      # visit root_path TODO: how to navigate there
      app.load do |page|
        page.submit!(
          user_email: "selena@example.com",
          user_password: "password",
          user_password_confirmation: "password",
        )
      end
    end

    Then "a confirmation is sent" do
      pending "allowing the mandatory name and username to be filled in"
      expect(
        page.find(".notice"),
      ).to have_content "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
    end
    # TODO: expand test to confirm email
  end

  context "with signup using omni auth" do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "123456",
        info: {
          email: "selena@example.com",
        },
      )
    end

    scenario "User signs up with GitHub successfully" do
      When "Selena signs up with a valid username" do
        visit root_path
        page.find("[type=submit][value=\"Sign in with GitHub\"]").click
      end

      Then "her profile is shown" do
        expect(page.find("[data-testid=notice]")).to have_content "Successfully authenticated from Github account."
      end
    end
  end
end
