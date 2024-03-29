# frozen_string_literal: true

require "rails_helper"

feature "User signup", :js do
  let(:app) { Pages::UserRegistration.new }

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

    Then "an error is returned as the name cannot be nil" do
      app.when_loaded do |page|
        expect(page.error_explanation).to have_content <<~EO_ERROR.chomp
          1 error prohibited this user from being saved:
          Name can't be blank
        EO_ERROR
      end
    end

    # TODO: expand test to allow signup? or edit and confirmation?
  end

  context "with signup using omni auth" do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "123456",
        info: {
          email: "selena@example.com",
          nickname: "SelenaSmall",
        },
      )
    end

    scenario "User signs up with GitHub successfully" do
      When "Selena signs up with a valid username" do
        Pages::App.new.load do |page|
          page.signin_with_github.click
        end
      end

      Then "her profile is shown" do
        Pages::Profile.new.when_loaded do |page|
          expect(page.profile_name).to have_content "SelenaSmall"
          expect(page).to have_current_path "/SelenaSmall"
          @profile_url = page.current_path
        end
      end

      When "she signs out" do
        Pages::Profile.new.when_loaded do |page|
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
        Pages::Profile.new.when_loaded do |page|
          # TODO: how to make this more robust
          expect(page.text.delete("\n")).to eq "🍐🍐pair with me profileSelenaSmall"
        end
      end
    end

    scenario "User with same username attempts to sign up" do
      When "Selena signs up with a valid username" do
        Pages::App.new.load do |page|
          page.signin_with_github.click
        end
      end

      Then "her profile name is SelenaSmall" do
        Pages::Profile.new.when_loaded do |page|
          expect(page.profile_name).to have_content "SelenaSmall"
        end
      end

      When "she signs out" do
        Pages::Profile.new.when_loaded do |page|
          page.sign_out.click
          expect(page).to have_content "Pair with me"
        end
      end

      When "the next user to sign up has the same nickname" do
        OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
          provider: "github",
          uid: "1",
          info: {
            email: "not_selena@example.com",
            nickname: "SelenaSmall",
          },
        )
      end

      And "they attempt to sign up" do
        Pages::App.new.load do |page|
          page.signin_with_github.click
        end
      end

      Then "they get an error that the username is already taken" do
        Pages::App.new.when_loaded do |page|
          expect(page.alert).to have_content "Username has already been taken"
        end
      end
    end
  end
end
