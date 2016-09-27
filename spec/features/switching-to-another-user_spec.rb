require 'spec_helper'

feature 'Switching to another user' do
  scenario "redirect to an user's archive" do
    visit '/'
    login_as_database_user
    visit '/admin/users'
    expect(page).to have_content 'Madek Admin'
    expect(page).to have_content 'Users'
    first('button', text: 'Switch to...').click
    expect(page).to have_content 'Media Archive'
  end
end
