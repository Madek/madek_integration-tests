require 'spec_helper'

describe 'Traversing from the UI to the API browser when signed in',
         type: :feature do
  it 'lets us pass and shows the proper auth info' do
    visit '/'
    expect(page).to have_content 'Media Archive'
    login_as_database_user
    expect(page).to have_content 'Mein Archiv'
    visit '/api/browser/index.html#/api'
    wait_until { page.has_content? 'API Browser' }
    wait_until { page.has_content? 'Relations' }
    api_click_on_relation_method 'auth-info', 'GET'
    wait_until { page.has_content? '200 OK' }
    expect(page).to have_content /authentication-method.*Session/
  end
end
