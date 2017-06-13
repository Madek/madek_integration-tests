require 'spec_helper'

BASE_URL = URI.parse(Capybara.app_host).freeze
USER = 'adam'

describe 'Accessing the API as a web client',
         type: :feature do

   before(:example) do
     is_cors_enabled = api_nrepl \
      '(-> (madek.api.utils.config/get-config) :services :api :cors_enabled)'
     expect(is_cors_enabled).to eq('true'), \
      'CORS must be enabled in settings for this spec!'
   end

   it 'works with CORS' do
     prepare_mock_api_client

     response = ajax_cors_test("#{BASE_URL}/api")
     expect(page).to have_content 'doing ajax cors request' # smokescreen
     expect(response['status']).to be 200
   end

   it 'works with CORS and Token' do
     user_api_token = get_new_user_api_token(USER)

     prepare_mock_api_client

     response = ajax_cors_test("#{BASE_URL}/api/auth-info", user_api_token)
     expect(response['status']).to be 200
     expect(response['body']['type']).to eq 'User'
     expect(response['body']['login']).to eq USER
   end

   it 'works with CORS and invalid Token' do
     prepare_mock_api_client

     response = ajax_cors_test("#{BASE_URL}/api/auth-info", 'NOT_A_VALID_TOKEN')
     expect(response['status']).to be 401
   end

end

def get_new_user_api_token(user)
  visit '/'
  login_as_database_user(login: user)
  within('.app-body-sidebar') { click_on 'Tokens' }
  click_on 'Neuen Token erstellen'
  click_on 'Token anlegen'
  token = find('samp.code').text
  expect(token.length).to be >= 20
  within('header') do
    find('.ui-header-user').click
    click_on 'Abmelden'
  end
  token
end
