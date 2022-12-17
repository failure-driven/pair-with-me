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
      When "Admin navigatates to admin to create a new promotion" do
        page.find("a", text: "admin").click
        page.find(".navigation a", text: "Promotions").click
        page.find("header a", text: "New promotion").click
      end

      And "creates a draft promotoin" do
        page.find("input[name=\"promotion[title]\"]").send_keys <<~EO_TITLE.chomp
          First ever promotion
        EO_TITLE
        page.find("textarea[name=\"promotion[body]\"]").send_keys <<~EO_MESSAGE
          Hello and welcome to pair-with.me
          some exciting updates are coming your way,

          hang in there
        EO_MESSAGE
        page.find(".form-actions input[type=submit]").click
      end

      Then "they are told creation was successfull" do
        expect(page.find(".flash").text).to eq "Promotion was successfully created."
      end

      When "they click on demo send" do
        page.find("[data-testid=demo-send]").click
      end

      Then "they are informed the demo email sent successfully" do
        expect(page.find(".flash").text).to eq "Demo email sent"
      end

      Then "they see a demo email sent to all admins" do
        open_email "selenasmall@example.com"
        expect(current_email.subject).to eq "[TEST] First ever promotion"
        expect(current_email.from).to eq(["failure.driven.blog+test@example.com"])
        expect(current_email.body).to have_content("Hello and welcome to pair-with.me")
      end
    end
  end
end
