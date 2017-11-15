require 'spec_helper'

describe 'Linking resources from webapp to admin', type: :feature do
  before do
    visit '/'
    login_as_database_user
  end

  it 'goes to a correct media entry page' do
    visit '/entries'
    all('.ui-resource .media-entry > a').first.click

    find('.ui-body-title-actions .dropdown-toggle').click

    admin_window = window_opened_by do
      find('.dropdown.open a', text: 'Zeige im Admin-Interface').click
    end

    within_window admin_window do
      expect(page).to have_content 'Media Entry:'
    end
  end
end
