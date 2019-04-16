require 'spec_helper'

feature 'Changing language changes data' do
  scenario 'ContextKey labels' do
    visit '/'
    login_as_database_user
    enable_uberadmin_mode

    update_context_key_labels(de: 'Titel', en: 'Title')

    visit '/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1/meta_data/edit/by_context'

    expect(collect_context_key_labels).to include('Titel')
    expect(collect_context_key_labels).not_to include('Title')

    change_language 'en'

    expect(collect_context_key_labels).to include('Title')
    expect(collect_context_key_labels).not_to include('Titel')
  end

  scenario 'Vocabulary labels' do
    pending
    visit '/'
    login_as_database_user

    update_vocabulary_labels(de: 'Rechte', en: 'Rights')

    visit '/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1/more_data'

    expect(collect_vocabulary_labels).to include('Rechte')
    expect(collect_vocabulary_labels).not_to include('Rights')

    change_language 'en'

    expect(collect_vocabulary_labels).to include('Rights')
    expect(collect_vocabulary_labels).to include('Rechte')
  end

  scenario 'MetaKey labels' do
    visit '/'
    login_as_database_user

    update_meta_key_labels(de: 'Copyright-Status', en: 'Copyright')

    visit '/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1/more_data'

    expect(collect_meta_key_labels).to include('Copyright-Status')
    expect(collect_meta_key_labels).not_to include('Copyright')

    change_language 'en'

    expect(collect_meta_key_labels).to include('Copyright')
    expect(collect_meta_key_labels).not_to include('Copyright-Status')
  end
end

def enable_uberadmin_mode
  within '.ui-header-user' do
    find('.dropdown-toggle').click
    within 'form[action="/session/uberadmin"]' do
      click_button 'In Admin-Modus wechseln'
    end
  end
end

def change_language(locale = 'de')
  select(locale, from: 'lang_switcher')
end

def collect_context_key_labels
  all('.app-body-content .form-body .form-label')
    .map(&:text)
    .map { |label| label.chomp(' *') }
end

def collect_meta_key_labels
  all('.meta-data-summary .media-data-title')
    .map(&:text)
end

def collect_vocabulary_labels
  all('.meta-data-summary h3')
    .map(&:text)
end

def update_context_key_labels(de:, en:)
  visit '/admin/contexts/media_content'
  within first('table.edit-context-keys tr[data-id]') do
    click_link 'Edit'
  end
  fill_in 'context_key[labels][de]', with: de
  fill_in 'context_key[labels][en]', with: en
  click_button 'Save'
end

def update_vocabulary_labels(de:, en:)
  visit '/admin/vocabularies/copyright/edit'
  fill_in 'vocabulary[labels][de]', with: de
  fill_in 'vocabulary[labels][en]', with: en
  click_button 'Save' 
end

def update_meta_key_labels(de:, en:)
  visit '/admin/meta_keys/copyright:license/edit'
  fill_in 'meta_key[labels][de]', with: de
  fill_in 'meta_key[labels][en]', with: en
  click_button 'Save'
end
