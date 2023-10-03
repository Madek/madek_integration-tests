require 'spec_helper'

feature 'Password' do
  scenario "resetting a users password" do
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

    within '#login_menu' do
      fill_in 'login', with: 'Adam'
      fill_in 'password', with: 'new password'
      find('[type=submit]').click
    end


    wait_until { current_path == '/my'}

  end
end
