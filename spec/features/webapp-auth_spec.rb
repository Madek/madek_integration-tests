require 'spec_helper'
#require 'spec_helper_feature'
#require 'spec_helper_feature_shared'

# TODO-UVB: this comes from webapp and must be tuned to run in integration tests

feature 'Auth delegation from webapp' do
  describe 'Signing in' do
    scenario 'from the home page' do
      visit '/'
      login_as_database_user
      expect(page).to have_content('Mein Archiv')
    end
    
    scenario 'from a protected path' do
      visit '/my/used_keywords'
      expect(page).not_to have_content('Meine Schlagworte')
      login_as_database_user
      expect(page).to have_content('Meine Schlagworte')
    end

    scenario 'from a public path using the login button in the head' do
      visit '/search'
      expect(page).to have_content('Volltext')
      within '.ui-header' do
        click_link 'Anmelden'
      end

      fill_in 'email-or-login', with: 'adam'
      click_on 'Weiter'
      fill_in 'password', with: 'password'
      click_on "Anmelden"

      expect(page).to have_content('Volltext')
    end
  end

  scenario "Sign out" do
    visit '/my/used_keywords'
    login_as_database_user
    expect(page).to have_content('Meine Schlagworte')
    within('header') do
      find('.ui-header-user').click
      click_on 'Abmelden'
    end
    expect(page).to have_content('Powerful Global Information System')
  end
end
