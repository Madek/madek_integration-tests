require 'spec_helper'

feature 'Deactivating a user' do
  scenario "another user" do
    visit '/'
    login_as_database_user
    visit "/admin/users/new_with_person"
    fill_in("user_first_name", with: "Deact")
    fill_in("user_last_name", with: "User")
    fill_in("user_login", with: "deact_user")
    fill_in("user_email", with: "deact_user@example.com") 
    fill_in("user_active_until", with: Date.yesterday)
    click_on("Save")
    visit("/")
    find("header .dropdown").click
    click_on("Abmelden")
    fill_in('email-or-login', with: "deact_user")
    click_on("Anmelden")
    expect(page).to have_content("Einloggen nicht möglich mit dieser E-Mail")
  end

  scenario "oneself" do
    visit '/'
    login_as_database_user
    user = User.find(login: "adam")
    visit "/admin/users/#{user.id}/edit"
    fill_in("user_active_until", with: Date.yesterday)
    click_on("Save")
    expect(page).to have_content("Please log in")
    visit("/my")
    expect(page).to have_selector("input[name='email-or-login']")
    fill_in("email-or-login", with: "adam")
    click_on("Anmelden")
    expect(page).to have_content("Einloggen nicht möglich mit dieser E-Mail")
  end
end
