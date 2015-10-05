require 'spec_helper'

describe 'The UI', type: :feature do
  it 'is up and running' do
    visit '/'
    expect(page).to have_content 'Media Archive'
  end
end
