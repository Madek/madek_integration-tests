require 'spec_helper'

describe 'Context view/use permission enforcement', type: :feature do
  it 'hides a restricted context tab until the user is granted use permission' do
    context_id = 'zzz-context-permission-test'
    label_de = 'ZZZ Restricted Context DE'
    label_en = 'ZZZ Restricted Context EN'

    visit '/'
    login_as_database_user
    user = User.find(login: 'adam')

    create_restricted_context(context_id, label_de, label_en)
    add_context_to_app_setting(:contexts_for_entry_edit, context_id)

    entry = MediaEntry.where(responsible_user_id: user.id).first
    visit "/entries/#{entry.id}"
    find('.icon-pen').click
    expect(page).not_to have_selector('.ui-tabs-item', text: label_de)

    grant_user_permission(context_id, login: 'adam', use: true)

    visit "/entries/#{entry.id}"
    find('.icon-pen').click
    expect(page).to have_selector('.ui-tabs-item', text: label_de)
  end

  it 'enforces view and use permissions independently' do
    context_id = 'zzz-context-permission-mixed'
    label_de = 'ZZZ Mixed Context DE'
    label_en = 'ZZZ Mixed Context EN'

    visit '/'
    login_as_database_user
    user = User.find(login: 'adam')

    create_restricted_context(context_id, label_de, label_en)
    add_context_to_app_setting(:contexts_for_entry_edit, context_id)
    add_context_to_app_setting(:contexts_for_entry_extra, context_id)

    entry = MediaEntry.where(responsible_user_id: user.id).first

    grant_user_permission(context_id, login: 'adam', view: true) # use stays false

    visit "/entries/#{entry.id}"
    find('.icon-pen').click
    expect(page).not_to have_selector('.ui-tabs-item', text: label_de),
      'view permission alone must not unlock the edit tab'

    listed_labels = JSON.parse(page.evaluate_async_script(<<~JS))
      var callback = arguments[arguments.length - 1];
      fetch('/entries/#{entry.id}.json', {credentials: 'same-origin'})
        .then(r => r.json())
        .then(j => callback(JSON.stringify(
          j.meta_data.contexts_for_entry_extra.map(c => c.context.label)
        )))
        .catch(e => callback(JSON.stringify(['ERROR: ' + e.toString()])))
    JS
    expect(listed_labels).to include(label_de),
      'view permission must surface the context among the entry-extra contexts'
  end

  def create_restricted_context(context_id, label_de, label_en)
    visit '/admin/contexts/new'
    fill_in 'context[id]', with: context_id
    fill_in 'context[labels][de]', with: label_de
    fill_in 'context[labels][en]', with: label_en
    uncheck 'Enabled for public view?'
    uncheck 'Enabled for public use?'
    click_on 'Create'

    visit "/admin/meta_keys?context_id=#{context_id}"
    fill_in 'search_term', with: 'madek_core:title'
    click_on 'Apply'
    within find('table tbody tr', text: 'madek_core:title') do
      click_link 'Add to the Context'
    end
  end

  def add_context_to_app_setting(field, context_id)
    visit "/admin/app_settings/#{field}/edit"
    current_value = find_field("app_setting[#{field}]").value
    fill_in "app_setting[#{field}]",
      with: [current_value, context_id].reject(&:blank?).join(', ')
    click_on 'Save'
  end

  def grant_user_permission(context_id, login:, view: false, use: false)
    visit '/admin/contexts'
    within find('table tbody tr', text: context_id) do
      click_link 'User Permissions'
    end
    click_link 'Create User Permission'
    click_link 'Choose user'

    fill_in 'search_term', with: login
    click_on 'Apply'
    within find('table tbody tr', text: login) do
      click_link 'Grant Context Permission'
    end
    use ? check('Can use?') : uncheck('Can use?')
    view ? check('Can view?') : uncheck('Can view?')
    click_on 'Save'
  end
end
