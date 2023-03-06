require 'spec_helper'

describe 'webapp: release info', type: :feature, ci_group: :release_info do
  before :example do
    # check needed config file, see spec setup for fixtures
    raise 'missing config!' unless File.exist?('../config/releases.yml')
    raise 'missing config!' unless File.exist?('../config/deploy-info.yml')
  end

  it 'shows version info in footer' do
    visit '/'

    info = first('.ui-footer-copy a')
    expect(info.text).to eq 'Madek 2.0.0'
    expect(info[:href]).to eq "#{Capybara.app_host}/release"
  end

  it 'shows deploy and release info on releases page' do
    visit '/release'

    expected_text = <<~TEXT.strip
      Deployment: Freitag, 5. August 2016 23:03, Build: Freitag, 5. August 2016 14:35
      Madek 2.0.0
      third release
      Changes:
      releases do not have name/info_url anymore!
      Vorherige Versionen
      Madek v1.0.0-1 \"Second\"
      second release (pre)
      Changes:
      fix: foo
      Madek 1.0.0 \"First\"
      first release
      Changes:
      feat: foo
      fix: bar
    TEXT

    expect(find('.ui-container.bright').text)
      .to eq expected_text
  end
end
