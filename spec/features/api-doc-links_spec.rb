require 'spec_helper'

describe 'API Docs in the API browser', type: :feature do
  it 'returns 200 for every doc link' do
    visit '/api/browser/'
    expect(page).to have_content 'Madek API Browser'

    link_counter = all("a[href*='/api/docs/']").size
    (0..link_counter - 1).map do |index|
      all("a[href*='/api/docs/']")[index].click
      expect(page).to have_content 'Madek API Documentation'
      visit '/api/browser/'
    end
  end
end
