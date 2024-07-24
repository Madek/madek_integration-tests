require 'spec_helper'

feature 'Notifications' do
  before(:each) do
    SmtpSetting.first.update(is_enabled: true)
    site_titles_hs = PgHstore.dump({de: 'Medienarchiv', en: 'Media Archive'}, true)
    AppSetting.first.update(site_titles: site_titles_hs)
    setup_smtp_port
  end

  scenario "work" do
    visit '/'
    user1 = User.find(login: 'petra')
    user2 = User.find(login: 'normin')
    admin = User.find(login: 'adam')
    notification_case = NotificationCase.find(label: 'transfer_responsibility')

    login_as_database_user(login: admin.login)
    add_user_to_beta_tester_group(admin)
    add_user_to_beta_tester_group(user2)
    click_on 'Notifications'
    click_on 'Details'
    expect(page).to have_content notification_case.label
    expect(page).to have_content notification_case.description
    logout(admin)

    login_as_database_user(login: user2.login)
    click_on 'Einstellungen'
    select('Englisch', from: 'emailsLocale')
    find('label', text: 'sofort').click
    click_on 'Einstellungen speichern'
    logout(user2)

    login_as_database_user(login: user1.login)
    visit '/my/content_media_entries'
    first('.media-entry').click
    media_entry_id = current_path.split('/').last
    media_entry = MediaEntry.find(id: media_entry_id)
    click_on 'Berechtigungen'
    find('a', text: 'Verantwortlichkeit übertragen').click
    find("input[type='text']").set user2.first_name
    first('.ui-menu-item').click
    click_on 'Übertragen'
    expect(page).to have_content \
      'Sie haben die Verantwortlichkeit für den Medieneintrag erfolgreich übertragen.'
    logout(user1)

    login_as_database_user(login: user2.login)
    notifs_link = find("a[href='/my/notifications']")
    expect(notifs_link.text).to eq 'Notifikationen(1)'
    notifs_link.click
    media_entry_title = MetaDatum.find(media_entry_id: media_entry_id,
                                       meta_key_id: 'madek_core:title').string
    expect(page).to have_content \
      "Verantwortlichkeit für Medieneintrag #{media_entry_title} wurde von " \
      "#{user1.first_name} #{user1.last_name} an Sie übertragen."
    accept_alert do
      click_on 'Alle Notifikationen löschen'
    end
    expect(page).to have_content 'Keine Einträge vorhanden'

    expect(Mail.all.count).to eq 1
    mail = Mail.first
    expect(mail.subject).to eq 'Media Archive: Transfer of responsability'
    expect(mail.to.first).to eq user2.email
    expect(mail.from.first).to eq SmtpSetting.first.default_from_address
  end

  def logout(user)
    visit '/my'
    find(id: "#{user.first_name} #{user.last_name}_menu").click
    click_on 'Abmelden'
    expect(page).to have_content 'Anmelden'
  end

  def add_user_to_beta_tester_group(user)
    visit '/admin/groups'
    fill_in 'search_terms', with: 'Notifications'
    click_on 'Apply'
    click_on 'Details'
    click_on 'Add user'
    fill_in 'search_term', with: user.login
    click_on 'Apply'
    click_on 'Add to the Group'
    expect(page).to have_content "The user #{user.login} has been added."
  end
end

