require 'spec_helper'

feature 'Password' do
  scenario "resetting a users password" do
    pending
    visit '/'
    login_as_database_user
    visit '/admin/users'
    wait_until(10){page.has_content? 'Madek Admin'}
    expect(page).to have_content 'Users'

    all("a", text: 'Edit').first.click
    fill_in 'user_password', with: 'new password' 
    click_button 'Save'


    visit '/'
    find("a", text: 'Adam Admin').click
    click_on 'Abmelden'

    expect(page).to have_content "Powerful Global Information System"

    if all('#login_menu [role="tablist"]').first
      click_link 'login_menu-tab-system'
    end

    fill_in 'email-or-login', with: 'Adam'
    click_on 'Anmelden'
    fill_in 'password', with: 'new password'
    click_on "Anmelden"

    wait_until { current_path == '/my'}

  end
end
