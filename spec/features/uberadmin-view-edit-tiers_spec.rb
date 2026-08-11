require 'spec_helper'

feature 'Uberadmin view/edit tiers' do
  # 'adam' is an existing admin persona; the uberadmin permission backfill
  # migration grants both 'uberadmin_view' and 'uberadmin_edit' to every
  # existing admin. uberadmin_view/edit is hierarchical: while edit is held,
  # view is implied and its checkbox is disabled, so revoking edit also
  # drops view as a side effect. To isolate the view-only tier we therefore
  # revoke edit first, then explicitly re-grant view in a second step.
  #
  # '71196fee-abdb-41c1-98f7-48d62c9f0ae7' is a restricted entry belonging to
  # another persona (normin), not viewable/editable by adam without uberadmin
  # (see spec/features/app/admin-mode_uberadmin_spec.rb in webapp).
  scenario 'view tier sees but cannot edit; edit tier can do both' do
    entry_id = '71196fee-abdb-41c1-98f7-48d62c9f0ae7'

    visit '/'
    login_as_database_user

    revoke_admin_permission(login: 'adam', label: 'Uberadmin (Edit)')
    grant_admin_permission(login: 'adam', label: 'Uberadmin (View)')

    visit "/entries/#{entry_id}"
    expect(page).to have_content 'Sie haben keine Zugriffsrechte für diesen Inhalt.'

    toggle_uberadmin_mode

    visit "/entries/#{entry_id}"
    expect(page).not_to have_content 'Sie haben keine Zugriffsrechte für diesen Inhalt.'

    visit "/entries/#{entry_id}/ask_delete"
    expect(page).to have_content 'Sie haben keine Zugriffsrechte für diesen Inhalt.'

    grant_admin_permission(login: 'adam', label: 'Uberadmin (Edit)')

    visit "/entries/#{entry_id}/ask_delete"
    expect(page).not_to have_content 'Sie haben keine Zugriffsrechte für diesen Inhalt.'
  end

  def open_user_menu
    find('.ui-header .ui-header-user .dropdown-toggle').click
  end

  def toggle_uberadmin_mode
    open_user_menu
    click_on 'In Admin-Modus wechseln'
    expect(page)
      .to have_selector '.ui-alert.success', text: 'Admin-Modus aktiviert!'
  end

  def open_admin_permissions_page(login:)
    visit '/admin/users'
    fill_in 'search_term', with: login
    click_on 'Apply'
    within find('table tbody tr', text: login) do
      if has_link?('Edit admin role')
        click_link 'Edit admin role'
      else
        click_link 'Grant admin role'
      end
    end
  end

  def revoke_admin_permission(login:, label:)
    open_admin_permissions_page(login: login)
    uncheck label
    click_on 'Save'
  end

  def grant_admin_permission(login:, label:)
    open_admin_permissions_page(login: login)
    check label
    click_on 'Save'
  end
end
