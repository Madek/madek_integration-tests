require 'spec_helper'

describe 'Traversing from the UI to the API browser when signedin',
         type: :feature do
  it 'lets us pass and shows the proper auth info' do
    visit '/'
    expect(page).to have_content 'Media Archive'

    find('input#login').set 'adam'
    find('input#password').set 'password'
    find('form#login_form').find('[type=submit]').click
    expect(page).to have_content 'Sie haben sich angemeldet.'
    visit '/api/browser/index.html#/api'
    wait_until{ page.has_content? 'The JSON-ROA Browser' }
    wait_until{ page.has_content? 'Relations' }
    api_click_on_relation_method 'auth-info', 'GET'
    wait_until{ page.has_content? '200 OK' }
    expect(page).to have_content /authentication-method.*Session/
  end
end
