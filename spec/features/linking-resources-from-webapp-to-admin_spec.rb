require 'spec_helper'

describe 'Linking resources from webapp to admin', type: :feature do
  before do
    visit '/'
    login_as_database_user
  end

  it 'goes to a correct media entry page' do
    visit '/entries'
    all('.ui-resource .media-entry > a').first.click

    go_to_admin

    expect(page).to have_content 'Madek Admin'
    expect(page).to have_content 'Media Entry:'
  end

  it 'goes to a correct collection page' do
    visit '/sets'
    all('.ui-resource .media-set > a').first.click

    go_to_admin

    expect(page).to have_content 'Madek Admin'
    expect(page).to have_content 'Sets :'
  end

  def go_to_admin
    anchor = find(
      '.ui-body-title-actions .dropdown a',
      text: 'Zeige im Admin-Interface',
      visible: false)

    visit anchor[:href]
  end
end
