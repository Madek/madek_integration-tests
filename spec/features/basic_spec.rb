require 'spec_helper'

describe 'The Webapp (UI) ', type: :feature do
  it 'is up and running.' do
    visit '/'
    expect(page).to have_content 'Media Archive'
    visit '/admin'
    expect(page).to have_content 'Please log in!'
    visit '/api/browser/index.html#/api'
    wait_until { page.has_content? 'Relations' }
  end
end
