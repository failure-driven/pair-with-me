# frozen_string_literal: true

require "rails_helper"

feature "Admin sends promotions", :js do
  context "when Selena is an admin and is logged in" do
    before do
      User.create!(
        email: "SelenaSmall@example.com",
        username: "SelenaSmall",
        password: "password",
        name: "Selena Small",
        user_actions: {admin: {can_administer: true}},
      )
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "5399968",
        info: {
          email: "SelenaSmall@example.com",
          nickname: "SelenaSmall",
        },
      )
      visit root_path
      page.find("[type=submit][value=\"Sign in with GitHub\"]").click
    end

    scenario "Send a test promotional email" do
      When "Admin navigatates to admin" do
        page.find("a", text: "admin").click
      end

      And "then to promotions" do
        pending "actual promotions and associated model existing"
        page.find(".navigation a", text: "Promotions")
      end
    end
  end
end
