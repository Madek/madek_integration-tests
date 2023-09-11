require 'spec_helper'

describe 'Traversing from the UI to the Admin UI when signed in',
         type: :feature do
  it 'lets us pass and shows the admin panel' do
    visit '/'
    expect(page).to have_content 'Media Archive'
    login_as_database_user
    expect(page).to have_content 'Mein Archiv'
    visit '/admin'
    expect(page).to have_content 'Madek Admin'
  end
end
