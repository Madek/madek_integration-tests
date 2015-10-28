require 'capybara/rspec'
require 'active_support/all'
require 'selenium-webdriver'
require 'pry'
require 'logger'
require 'faker'
require 'helpers/misc'
require 'helpers/configuration_management'

RSpec.configure do |config|
  config.include Helpers::Misc
  config.include Helpers::ConfigurationManagement

  port = Integer(ENV['REVERSE_PROXY_HTTP_PORT'].present? &&
                 ENV['REVERSE_PROXY_HTTP_PORT'] || '3100')

  Capybara.current_driver = :selenium
  Capybara.app_host = "http://localhost:#{port}"
  Capybara.server_port = port

  if ENV['FIREFOX_ESR_PATH'].present?
    Selenium::WebDriver::Firefox.path = ENV['FIREFOX_ESR_PATH']
  end

  config.before(:all) do |_example|
    Capybara.current_driver = :selenium
    Capybara.app_host = "http://localhost:#{port}"
    Capybara.server_port = port

    $logger = Logger.new(STDOUT)
    $logger.level = Logger::WARN
  end

  config.before(:each) do |_example|
    Capybara.current_driver = :selenium
    Capybara.app_host = "http://localhost:#{port}"
    Capybara.server_port = port
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  begin
    config.filter_run :focus
    config.run_all_when_everything_filtered = true

    config.warnings = false

    config.default_formatter = 'doc' if config.files_to_run.one?

    config.order = :random

    # initialize global pseudo randomization based tree-id
    config.before :all do
      @spec_seed = \
        ENV['SPEC_SEED'].presence.try(:strip) || `git log -n1 --format=%T`.strip
      puts "SPEC_SEED #{@spec_seed} set env SPEC_SEED to force value"
      Kernel.srand Integer(@spec_seed, 16)
    end
    config.after :all do
      puts "SPEC_SEED #{@spec_seed} set env SPEC_SEED to force value"
    end

    config.after(:each) do |example|
      take_screenshot unless example.exception.nil?
    end

    def take_screenshot(screenshot_dir = nil, name = nil)
      screenshot_dir ||= File.join(Dir.pwd, 'tmp')
      begin
        Dir.mkdir screenshot_dir
      rescue
        nil
      end
      name ||= "screenshot_#{Time.now.iso8601.gsub(/:/, '-')}.png"
      path = File.join(screenshot_dir, name)
      case Capybara.current_driver
      when :selenium, :selenium_chrome
        begin
          page.driver.browser.save_screenshot(path)
        rescue
          nil
        end
      when :poltergeist
        begin
          page.driver.render(path, full: true)
        rescue
          nil
        end
      else
        Rails.logger.warn 'Taking screenshots is not implemented for ' \
        "#{Capybara.current_driver}."
      end
    end

  end
end
