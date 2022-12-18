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
      Pages::App.new.load do |page|
        page.signin_with_github.click
      end
    end

    scenario "Send a test promotional email" do
      When "Admin navigatates to admin to create a new promotion" do
        Pages::App.new.when_loaded do |page|
          page.admin.click
        end
        Pages::Admin.new.when_loaded do |page|
          page.navigate_to("Promotions")
          page.new_promotion.click
        end
      end

      And "creates a draft promotion" do
        Pages::Admin.new.when_loaded do |page|
          body = <<~EO_MESSAGE
            Hello and welcome to pair-with.me
            some exciting updates are coming your way,

            hang in there
          EO_MESSAGE
          page.submit!(
            :promotion,
            title: "First ever promotion",
            body: body,
          )
        end
      end

      Then "they are told creation was successfull" do
        Pages::Admin.new.when_loaded do |page|
          expect(page.flash.text).to eq "Promotion was successfully created."
        end
      end

      When "they click on demo send" do
        Pages::Admin.new.when_loaded do |page|
          page.demo_send.click
          find("[data-testid=demo-send]").click
        end
      end

      Then "they are informed the demo email sent successfully" do
        Pages::Admin.new.when_loaded do |page|
          expect(page.flash.text).to eq "Demo email sent"
        end
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
