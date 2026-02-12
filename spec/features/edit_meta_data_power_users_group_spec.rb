require 'spec_helper'

describe 'Disabling all meta data edit tab for power users', type: :feature do
  it 'works' do
    visit '/'
    login_as_database_user
    group = database[<<~SQL].first
      SELECT *
      FROM groups
      WHERE type = 'Group'
      LIMIT 1
    SQL
    visit('/admin/app_settings')
    within("#edit_meta_data_power_users_group_id") { click_on "Edit" }
    fill_in("app_setting[edit_meta_data_power_users_group_id]", with: group[:id])
    click_on("Save")
    visit("/my/content_media_entries")
    find(".link.ui-thumbnail-image-wrapper.ui-link").click
    find(".icon-pen").click
    expect(page).not_to have_selector(".ui-tabs-item", text: "All metadata")
  end
end
