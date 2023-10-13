require 'spec_helper'

describe 'Modifying core meta key', type: :feature do
  it 'works' do
    visit '/'
    login_as_database_user

    visit '/admin/meta_keys'
    find('#search_term').set('madek_core:title')
    click_on 'Apply'
    within "tr[data-id='madek_core:title']" do
      click_on 'Edit'
    end

    find('#meta_key_labels_de').set('newest label DE')
    find('#meta_key_labels_en').set('newest label EN')
    find('#meta_key_descriptions_de').set('newest description DE')
    find('#meta_key_descriptions_en').set('newest description EN')
    find('#meta_key_hints_de').set('newest hint DE')
    find('#meta_key_hints_en').set('newest hint EN')
    find('#meta_key_documentation_urls_de').set('newest documentation url DE')
    find('#meta_key_documentation_urls_en').set('newest documentation url EN')

    click_on 'Save'
    click_on 'Edit'

    expect(find('#meta_key_labels_de').value).to eq 'newest label DE'
    expect(find('#meta_key_labels_en').value).to eq 'newest label EN'
    expect(find('#meta_key_descriptions_de').value).to eq 'newest description DE'
    expect(find('#meta_key_descriptions_en').value).to eq 'newest description EN'
    expect(find('#meta_key_hints_de').value).to eq 'newest hint DE'
    expect(find('#meta_key_hints_en').value).to eq 'newest hint EN'
    expect(find('#meta_key_documentation_urls_de').value).to eq 'newest documentation url DE'
    expect(find('#meta_key_documentation_urls_en').value).to eq 'newest documentation url EN'

    visit '/my/content_media_entries'
    find('.ui-resource .link').click
    find('.icon-pen').click
    click_on 'Alle Daten'

    expect(page).not_to have_content 'new label DE'
    expect(page).to have_content 'newest label DE'
    expect(page).not_to have_content 'new hint DE'
    expect(page).to have_content 'newest hint DE'
  end
end
