require 'spec_helper'

feature 'Meta-Data-People (with Roles)' do
  scenario "works" do
    visit '/'
    user = User.find(login: "adam")
    login_as_database_user(login: user.login)
    visit '/admin/roles_lists'

    click_on "Create a Roles List"
    roles_list_label_de = "Roles List DE"
    roles_list_label_en = "Roles List EN"
    fill_in "roles_list[labels][de]", with: roles_list_label_de 
    fill_in "roles_list[labels][en]", with: roles_list_label_en
    click_on "Save"

    visit "/admin/meta_keys/madek_core:authors/edit"
    select roles_list_label_de, from: "meta_key_roles_list_id"
    click_on "Save"

    visit "/admin/roles"
    click_on "Create a Role"
    role_label_de = "Role DE"
    role_label_en = "Role EN"
    fill_in "role[labels][de]", with: role_label_de
    fill_in "role[labels][en]", with: role_label_en
    click_on "Save"
    role = Role.first

    visit "/admin/roles_lists"
    click_on "Details"
    click_on "Add role"
    click_on "Add to the Roles List"

    visit "/my"
    entry = MediaEntry.where(responsible_user_id: user.id).first
    visit "/entries/#{entry.id}"
    find(".icon-pen").click
    fill_in "media_entry[meta_data][madek_core:title][]", with: "Test Media Entry"
    fill_in "media_entry[meta_data][madek_core:copyright_notice][]", with: "Test Copyright Notice"
    person = Person.first
    find(".ui-form-group", text: "Autor/in").find("input").set person.first_name
    find(".ui-autocomplete__person-suggestion").click
    click_on "Funktion hinzufügen"
    find(".ui-menu-item").click
    click_on "Übernehmen"
    click_on "Speichern"
    expect(first(".ui-tag-cloud-person-roles-item").text).to eq "#{person.first_name} #{person.last_name}\n:#{role_label_de}"

    visit "/api/browser/index.html"
    md = MetaDatum.where(media_entry_id: entry.id, meta_key_id: "madek_core:authors").first
    mdp = MetaDatum::Person.where(meta_datum_id: md.id).all.first
    visit "/api/meta-data-people/#{mdp.id}"
    expect(page.text).to match /"person_id":"#{person.id}"/
    expect(page.text).to match /"role_id":"#{role.id}"/
  end
end
