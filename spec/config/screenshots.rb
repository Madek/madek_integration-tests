require 'capybara/rspec'

def take_screenshot(screenshot_dir = nil, name = nil)
  screenshot_dir ||= File.join(Dir.pwd, 'tmp', 'error-screenshots')
  name ||= "screenshot_#{DateTime.now.utc.iso8601.tr(':', '-')}"
  name = "#{name}.png" unless name.end_with?('.png')

  path = File.join(Dir.pwd, screenshot_dir, name)
  FileUtils.mkdir_p(File.dirname(path))

  case Capybara.current_driver
  when :selenium, :selenium_chrome
    begin
      page.driver.browser.save_screenshot(path)
    rescue
      nil
    end
  else
    warn "Taking screenshots is not implemented for #{Capybara.current_driver}."
  end
end
