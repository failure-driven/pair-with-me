# frozen_string_literal: true

require "rails_helper"

feature "Create a user on the fly if they exist in Github", :js do
  before do
    allow_any_instance_of( # rubocop:disable RSpec/AnyInstance
      FindPairs::GitHub::Api,
    ).to receive(:fetch_json).and_return({})
  end

  scenario "Create a user on the fly if they exist in GitHub" do
    Given "there is a saramic user in GitHub" do
      allow_any_instance_of( # rubocop:disable RSpec/AnyInstance
        FindPairs::GitHub::Api,
      ).to receive(:fetch_json).and_return({
        "login" => "saramic",
        "id" => 278723,
        "name" => "Michael Milewski",
      })
    end

    When "someone visits /saramic" do
      Profile.new.load(username: "saramic")
    end

    Then "Saramic's profile is fetched and displayed" do
      Profile.new.when_loaded do |page|
        expect(page.profile_name).to have_content "saramic"
      end
    end
  end

  context "when user SelenaSmall has an account on pair-with.me" do
    before do
      User.create!(
        username: "SelenaSmall",
        uid: 5399968,
        provider: "github",
        email: "5399968+SelenaSmall@users.noreply.github.com",
        name: "Selena Small",
        password: SecureRandom.hex(32),
      )
    end

    scenario "Redirect to correct name for a user" do
      When "someone visits /selenasmall" do
        Profile.new.load(username: "selenasmall")
      end

      Then "Saramic's profile is fetched and displayed" do
        Profile.new.when_loaded do |page|
          expect(page).to have_current_path "/SelenaSmall"
          expect(page.profile_name).to have_content "SelenaSmall"
        end
      end
    end
  end

  scenario "When the user cannot be found in GitHub" do
    When "someone visits /not-a-user" do
      Profile.new.load(username: "not-a-user")
    end

    Then "the user is redirect to the root page with an notice saying user cannot be found" do
      expect(page).to have_current_path root_path, ignore_query: true
      expect(
        page.find("[data-testid=notice]"),
      ).to have_text "user not found"
    end
  end
end
