# frozen_string_literal: true

require "rails_helper"

feature "Create and claim pairing counter party", :js do
  context "when Michael is logged via his github" do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "278723",
        info: {
          email: "saramic@example.com",
          nickname: "saramic",
        },
      )
      Pages::App.new.load do |page|
        page.signin_with_github.click
      end
    end

    scenario "Manual process creates pairing counter parites which are later claimed" do # rubocop:disable RSpec/NoExpectationExample
      Given "Michael has a pairing history with a number of users including Selena" do
        # TODO: some script that generates
        user_saramic = User.find_by(username: "saramic")
        Pair.create!(
          author: user_saramic,
          co_author: User.create!(
            username: "SelenaSmall",
            uid: "5399968",
            provider: "github",
            email: "5399968_NO_EMAIL@example.com",
            name: "Selena Small",
            password: SecureRandom.hex(32),
          ),
        )
        Pair.create!(
          author: User.create!(
            username: "j-tws",
            uid: "109884160",
            provider: "github",
            email: "109884160_NO_EMAIL@example.com",
            name: "109884160_NO_NAME",
            password: SecureRandom.hex(32),
          ),
          co_author: user_saramic,
        )
      end

      When "Michael's profile is viewed" do
        Pages::Profile.new.load(username: "saramic")
      end

      Then "Selena can be seen as an un-verified pair" do
        Pages::Profile.new.when_loaded do |page|
          expect(page.profile_name).to have_content "saramic"
          expect(page.pairs.map(&:username).map(&:text)).to contain_exactly("SelenaSmall", "j-tws")
        end
      end

      When "her profile is viewed" do
        Pages::Profile.new.when_loaded do |page|
          page.visit_pair("SelenaSmall")
        end
      end

      Then "it is un-claimed" do
        Pages::Profile.new.when_loaded do |page|
          expect(page.profile_name).to have_content "SelenaSmall"
          expect(page.status).to have_content "un-claimed"
        end
      end

      When "Selena logs in via GitHub" do
        OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
          provider: "github",
          uid: "5399968",
          info: {
            email: "SelenaSmall@example.com",
            nickname: "SelenaSmall",
          },
        )
        Pages::Profile.new.when_loaded do |page|
          page.claim.click
        end
      end

      Then "she successfully claims her account" do
        Pages::Profile.new.when_loaded do |page|
          expect(page.profile_name).to have_content "SelenaSmall"
          expect(page.status).to have_content "claimed"
        end
      end

      And "verify the pairing with Michael"
    end
  end
end
