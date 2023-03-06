require 'spec_helper'

BASE_URL = URI.parse(Capybara.app_host).freeze

describe 'API configured', type: :feature, ci_group: :cors_disabled do

  it 'does not support CORS if disabled in settings' do
   is_cors_enabled = api_nrepl \
     '(-> (madek.api.utils.config/get-config) :services :api :cors_enabled)'

   expect(is_cors_enabled).to eq('false'), \
     'CORS must be disabled in settings for this spec!'

    prepare_mock_api_client
    response = ajax_cors_test("#{BASE_URL}/api")
    expect(page).to have_content 'doing ajax cors request' # smokescreen
    expect(response['status']).to be 0
  end

end
