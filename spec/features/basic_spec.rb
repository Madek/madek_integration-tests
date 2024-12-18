require 'spec_helper'

describe 'Basic smoke tests' do
  context 'The Webapp (UI)', type: :feature do 
    it 'is up and running.' do
      visit '/'
      expect(page).to have_content 'Media Archive'
      visit '/admin'
      expect(page).to have_content 'Please log in!'
      visit '/api/browser/index.html#/api'
      wait_until { page.has_content? 'Relations' }
    end
  end

  context 'Mailing Setup' do
    it 'works' do
      user = User.find(login: 'normin')
      email = FactoryBot.create(:email, user_id: user.id)
      wait_until(5) do
        Mail.all.count == 1
      end
      expect(Mail.first.to.first).to eq email.to_address
      expect(email.reload.is_successful).to be true
    end
  end
end
