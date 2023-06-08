require 'spec_helper'

describe 'Sign in via new auth service', type: :feature do
  scenario 'sign in from new auth results in a valid session in webapp' do
    visit '/auth/sign-in'
    fill_in 'email', with: 'frederick.dickinson@wehnerjewe.org'
    click_on 'Continue'
    click_on 'Madek Password Authentication'
    fill_in :password, with: 'password'
    click_on 'Submit'
    uri = Addressable::URI.parse(current_url)
    expect(uri.path).to be== '/my'
    expect(page).to have_content 'Adam'
  end
end
