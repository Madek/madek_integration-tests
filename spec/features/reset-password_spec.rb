require 'spec_helper'

feature 'Password' do
  before(:each) do
    SmtpSetting.first.update(is_enabled: true)
  end

  scenario "resetting a users password" do
    user = create(:user, password_sign_in_enabled: false)

    visit '/'
    fill_in('email-or-login', with: user.email)
    click_on('Anmelden')
    expect(page).to have_content "Einloggen nicht möglich mit dieser E-Mail"

    visit '/'
    login_as_database_user
    visit "/admin/users/#{user.id}/edit"
    find("#user_password_sign_in_enabled").click
    click_on("Save")
    find("#current-user").click
    click_on("Logout")

    visit("/auth/sign-in/auth-systems/password/password/forgot")
    fill_in('email-or-login', with: user.email)
    click_on('E-Mail senden')

    expect(page).to have_content \
      "Es wurde ein Mail mit einem Link zum Zurücksetzen des Passworts gesendet."

    assert_received_email(to: user.email, subject: "Media Archive: Neues Passwort setzen")

    find("a[href='/auth/sign-in/auth-systems/password/password/reset']").click
    token = UserPasswordReset.first.token
    fill_in("token", with: token)
    click_on("Weiter")

    fill_in("password", with: "notgood")
    click_on("Weiter")
    expect(page).to have_content "Bitte Passwortregel beachten"
    fill_in("password", with: "Bholenath123")
    click_on("Weiter")

    expect(page).to have_content "Das Passwort wurde erfolgreich zurückgesetzt."

    assert_received_email(to: user.email, subject: "Media Archive: Passwort geändert")

    click_on("Klicken Sie hier, um sich anzumelden.")
    fill_in('email-or-login', with: user.email)
    click_on('Weiter')
    fill_in("password", with: "Bholenath123")
    click_on('Anmelden')
    click_on('Nutzungsbedingungen akzeptieren')
    expect(page).to have_content 'Mein Archiv'
    expect(page).to have_content "#{user.first_name} #{user.last_name}"
  end
end
