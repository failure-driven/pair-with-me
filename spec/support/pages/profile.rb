# frozen_string_literal: true

class Profile < SitePrism::Page
  set_url "/{username}"

  element :profile_name, "[data-testid=profile-name]"
  element :sign_out, "[data-testid=sign-out]"
  element :status, "[data-testid=status]"
  element :claim, "[data-testid=claim]"

  sections :pairs, "[data-testid|=pair]" do
    element :username, "a[data-testid=username]"
  end

  def visit_pair(username)
    pairs.find { |pair| pair.username.text == username }.username.click
  end
end
