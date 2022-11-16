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
        Profile.new.when_loaded do |page|
          expect(page.profile_name).to have_content "selena"
          @profile_url = page.current_path
        end
      end

      When "she signs out" do
        Profile.new.when_loaded do |page|
          page.sign_out.click
        end
      end

      Then "she is on the landing page" do
        expect(page).to have_current_path "/"
      end

      When "she visits her public profile page" do
        visit @profile_url
      end

      Then "she can see her public profile" do
        Profile.new.when_loaded do |page|
          # TODO: how to make this more robust
          expect(page.text).to eq "🍐🍐 pair with me profile\nselena"
        end
      end
    end
  end
end
