require "rails_helper"

RSpec.describe "Logging in to the system" do
  scenario "the user logs in" do
    visit "/"

    expect(page).not_to have_content("Hello")
  end
end
