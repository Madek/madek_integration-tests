require 'helpers/misc'
require 'helpers/mock_api_client'

# top-level wait helper (non-module version, callable from RSpec contexts directly)
def wait_until(wait_time = 60, sleep_secs: 0.1, &block)
  Timeout.timeout(wait_time) do
    sleep(sleep_secs) until (value = yield)
    value
  end
end

RSpec.configure do |config|
  config.include Helpers::Misc
  config.include Helpers::MockApiClient
end
