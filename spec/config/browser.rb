require 'pry'
require 'capybara/rspec'
require 'selenium-webdriver'

MADEK_HTTP_PORT = Integer(ENV['REVERSE_PROXY_HTTP_PORT'].presence || '3100')
MADEK_HTTP_BASE_URL = "http://localhost:#{MADEK_HTTP_PORT}"

Capybara.app_host = MADEK_HTTP_BASE_URL

firefox_bin_path = if ENV['TOOL_VERSIONS_MANAGER'] == 'mise'
  Pathname.new(`mise where firefox`.strip).join('bin/firefox').expand_path.to_s
else
  Pathname.new(`asdf where firefox`.strip).join('bin/firefox').expand_path.to_s
end
Selenium::WebDriver::Firefox.path = firefox_bin_path

Capybara.register_driver :selenium do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  opts = Selenium::WebDriver::Firefox::Options.new(profile: profile)
  Capybara::Selenium::Driver.new(app, browser: :firefox, options: opts)
end

Capybara.default_driver = :selenium
Capybara.current_driver = :selenium

Capybara.configure do |config|
  config.default_max_wait_time = 15
end
