# frozen_string_literal: true

require "rails_helper"

describe "It works root rails demo page", :js do
  let(:it_works_root) { ItWorksRoot.new }

  it "I have rails" do
    When "user visits the app" do
      it_works_root.load
    end

    Then "user sees they are on rails" do
      expect(it_works_root.rails_version.text).to match(/7.0.4/)
      expect(it_works_root.ruby_version.text).to match(/ruby 3.1.2/)
    end
  end
end
