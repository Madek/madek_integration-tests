require 'capybara/rspec'
require 'active_support/all'
require 'selenium-webdriver'
require 'pry'
require 'logger'
require 'faker'
require 'helpers/misc'
require 'helpers/configuration_management'
require 'helpers/mock_api_client'

RSpec.configure do |config|
  config.include Helpers::Misc
  config.include Helpers::ConfigurationManagement
  config.include Helpers::MockApiClient

  port = Integer(ENV['REVERSE_PROXY_HTTP_PORT'].presence || '3100')

  firefox_bin_path =
    Pathname.new(`asdf where firefox`.strip).join('bin/firefox').expand_path
  Selenium::WebDriver::Firefox.path = firefox_bin_path.to_s

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(
      app,
      browser: :firefox)
  end

  Capybara.app_host = "http://localhost:#{port}"
  Capybara.server_port = port

  config.before(:all) do |example|
    set_driver example
    Capybara.app_host = "http://localhost:#{port}"
    Capybara.server_port = port

    $logger = Logger.new(STDOUT)
    $logger.level = Logger::WARN
  end

  config.before(:each) do |example|
    set_driver example
    Capybara.app_host = "http://localhost:#{port}"
    Capybara.server_port = port
  end

  def set_driver example = nil
    example_driver =
      begin
        example.metadata[:driver].presence.try(:to_sym)
      rescue Exception => _
        nil
      end
    Capybara.current_driver = \
      ENV['CAPYBARA_DRIVER'].presence.try(:to_sym) \
      || example_driver || :selenium
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
