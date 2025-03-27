require 'spec_helper'

feature 'Displaying a banner message for logged in user' do
  scenario 'works' do
    visit '/'
    admin = User.find(login: 'adam')
    login_as_database_user login: admin.login, password: 'password'
    visit "/admin/app_settings"
    find("tr#banner_messages").find("a", text: "Edit").click
    banner_messages_de = "Dies ist eine Banner-Meldung."
    find("#app_setting_banner_messages_de").set(banner_messages_de)
    click_on "Save"
    visit "/my"
    alert_css = "#app-alerts .warning" 
    find(alert_css, text: banner_messages_de)
    select "en", from: "lang_switcher"
    find(alert_css, text: banner_messages_de)
    find(".ui-header-user").click
    click_on "Log out"
    expect(page).not_to have_selector(alert_css, text: banner_messages_de)
  end
end
