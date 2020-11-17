require "rails_helper"

RSpec.describe "Logging in to the system" do
  fixtures :users

  let(:user) { users(:mctester) }

  context "user does not require 2FA" do
    scenario "the user logs in" do
      visit "/"

      expect(page).not_to have_content("Hello")
      fill_in "Email", with: user.email
      fill_in "Password", with: "password"
      click_on "Log in"

      expect(page).to have_content("Hello")
      expect(page).to have_content(user.email)
    end
  end

  context "user does require 2FA" do
    before do
      user.update!(requires_two_factor_auth: true)
    end

    scenario "the user logs in with 2FA" do
      visit "/"

      expect(page).not_to have_content("Hello")
      fill_in "Email", with: user.email
      fill_in "Password", with: "password"
      click_on "Log in"

      expect(page).not_to have_content("Hello")

      # Do something
      expect(page).to have_content("Hello")
      expect(page).to have_content(user.email)
    end
  end
end
