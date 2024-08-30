require 'spec_helper'

feature 'Soft-delete and restore an entry' do
  scenario "works" do
    visit '/'
    entry = MediaEntry.all.detect do |e|
      e.is_published and e.deleted_at.nil? \
        and MetaDatum.where(media_entry_id: e.id,
                            meta_key_id: 'madek_core:copyright_notice').first
    end
    user = User.find(id: entry.responsible_user_id)
    login_as_database_user login: user.login, password: 'password'
    visit "/entries/#{entry.id}"
    find(id: "Weitere Aktionen_menu").click
    click_on("Medieneintrag löschen")
    click_on("Löschen")
    visit "/entries/#{entry.id}"
    expect(page).to have_content "ActiveRecord::RecordNotFound: Couldn't find MediaEntry"
    visit "/files/#{entry.media_file.id}"
    expect(page).to have_content "ActiveRecord::RecordNotFound: MediaFile not found"
    visit "/media/#{entry.media_file.previews.first.id}"
    expect(page).to have_content "ActiveRecord::RecordNotFound: Preview not found"

    find(id: "#{user.first_name} #{user.last_name}_menu").click
    click_on("Abmelden")

    admin = User.find(login: 'adam')
    login_as_database_user login: admin.login, password: 'password'

    visit "/entries/#{entry.id}"
    expect(page).to have_content "ActiveRecord::RecordNotFound: Couldn't find MediaEntry"
    find(id: "#{admin.first_name} #{admin.last_name}_menu").click
    click_on "In Admin-Modus wechseln"
    # visit current_path
    find("#app-alerts .error",
         text: "Dieser Medieneintrag wurde gelöscht und ist für Benutzer nicht mehr sichtbar.")
    
    visit "/admin/media_entries"
    fill_in "search_term", with: entry.id
    select "Yes", from: "filter[is_deleted]"
    click_on "Apply"
    within find("tr[data-id='#{entry.id}']") do
      find('.glyphicon-eye-open').click
    end
    click_on "Media-File"
    expect(find(".page-header h1")).to have_content "Deleted"
    visit "/admin/media_entries/#{entry.id}"

    accept_alert do
      click_on "Restore"
    end

    find(".alert.alert-success", text: "Success! Media-Entry restored successfully.")

    visit "/my"
    find(id: "#{admin.first_name} #{admin.last_name}_menu").click
    click_on("Abmelden")

    login_as_database_user login: user.login, password: 'password'
    visit "/entries/#{entry.id}"
    expect(page).not_to have_content "ActiveRecord::RecordNotFound: Couldn't find MediaEntry"
    title = MetaDatum.where(media_entry_id: entry.id,
                            meta_key_id: 'madek_core:title').first.string
    expect(page).to have_content title
  end
end
