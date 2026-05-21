require 'logger'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

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

  config.before(:all) do
    $logger = Logger.new(STDOUT)
    $logger.level = Logger::WARN
  end

  config.before(:each) do |example|
    unless ENV['CIDER_CI_TRIAL_ID'].present?
      db_clean
      db_restore_data
    end

    set_driver example
    Capybara.app_host = MADEK_HTTP_BASE_URL
    Capybara.server_port = MADEK_HTTP_PORT
  end

  config.after(:each) do |example|
    take_screenshot unless example.exception.nil?
  end
end

def set_driver(example = nil)
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
