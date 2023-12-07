require 'spec_helper'

describe 'Linking from admin people to webapp people', type: :feature do
  it 'goes to a correct person page' do
    visit '/'
    login_as_database_user
    visit '/admin/people'
    fill_in 'filter[search_term]', with: 'Adam Admin'
    click_button 'Apply'

    ui_window = window_opened_by do
      within 'table tbody tr:first-of-type' do
        click_link 'Web-App'
      end
    end

    within_window ui_window do
      expect(page).to have_content 'Adam Admin'
      expect(current_path).to start_with '/people/'
    end
  end
end
