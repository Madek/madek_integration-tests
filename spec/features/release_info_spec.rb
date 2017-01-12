require 'spec_helper'

describe 'webapp: release info', type: :feature do
  before :example do
    # check needed config file, see spec setup for fixtures
    raise 'missing config!' unless File.exist?('../config/releases.yml')
    raise 'missing config!' unless File.exist?('../config/deploy-info.yml')
  end

  it 'shows version info in footer' do
    visit '/'

    info = first('.ui-footer-copy a')
    expect(info.text).to eq 'Madek v1.0.0-1 Second'
    expect(info[:href]).to eq "#{Capybara.app_host}/release"
  end

  it 'shows deploy and release info on releases page' do
    visit '/release'

    expect(find('.ui-container.bright').text)
      .to eq <<-TEXT.strip_heredoc.tr("\n", ' ').gsub('  ', ' ').strip

        Letztes Deployment: Freitag, 5. August 2016 14:35
        Madek v1.0.0-1 "Second"
        second release (pre)

        Vorherige Versionen
        Madek 1.0.0 "First"
        first release

      TEXT
  end

end
