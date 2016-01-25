require 'spec_helper'

describe 'Traversing from the UI to the Admin UI when signed in',
         type: :feature do
  it 'lets us pass and shows the admin panel' do
    visit '/'
    expect(page).to have_content 'Media Archive'
    find('input#login').set 'adam'
    find('input#password').set 'password'
    find('form#login_form').find('[type=submit]').click
    expect(page).to have_content 'Sie haben sich angemeldet.'
    visit '/admin'
    expect(page).to have_content 'Madek Admin'
  end
end
