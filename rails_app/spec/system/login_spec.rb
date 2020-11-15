require "rails_helper"

RSpec.describe "Logging in to the system" do
  fixtures :users

  let(:user) { users(:mctester) }

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
