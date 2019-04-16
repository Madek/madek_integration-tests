require 'spec_helper'

feature 'Changing translations is reflected in apps' do
  context 'Webapp' do
    scenario 'Vocabulary labels' do
      visit '/'
      login_as_database_user

      update_vocabulary_label('Credits')

      visit '/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1/more_data'

      expect(collect_vocabulary_labels).to include('Credits')
      expect(collect_vocabulary_labels).not_to include('New Label')

      update_vocabulary_label('New Label')

      visit '/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1/more_data'

      expect(collect_vocabulary_labels).to include('New Label')
      expect(collect_vocabulary_labels).not_to include('Credits')
    end

    scenario 'MetaKey labels' do
      visit '/'
      login_as_database_user

      visit '/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1/more_data'

      expect(collect_meta_key_labels).to include('Copyright-Status')
      expect(collect_meta_key_labels).not_to include('New Label')

      update_meta_key_label('New Label')

      visit '/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1/more_data'

      expect(collect_meta_key_labels).to include('New Label')
      expect(collect_meta_key_labels).not_to include('Copyright-Status')
    end

    scenario 'ContextKey labels' do
      visit '/'
      login_as_database_user
      enable_uberadmin_mode

      visit '/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1/meta_data/edit/by_context/media_content'

      expect(collect_context_key_labels).to include('Titel')
      expect(collect_context_key_labels).not_to include('New Label')

      update_context_key_label('New Label')

      visit '/entries/924057ea-5f9a-4a81-85dc-aa067577d6f1/meta_data/edit/by_context/media_content'

      expect(collect_context_key_labels).to include('New Label')
      expect(collect_context_key_labels).not_to include('Titel')
    end
  end

  context 'API' do
    scenario 'Vocabulary label' do
      visit '/'
      login_as_database_user

      update_vocabulary_label 'Copyright'
      visit '/api/browser/'
      wait_until { first('input#url') }
      first('input#url').set '/api/vocabularies/copyright'
      find('button#get').click
      expect(json_data['label']).to eq 'Copyright'

      update_vocabulary_label 'Rechte'
      visit '/api/browser/'
      wait_until { first('input#url') }
      first('input#url').set '/api/vocabularies/copyright'
      find('button#get').click
      expect(json_data['label']).to eq 'Rechte'
    end

    scenario 'MetaKey label' do
      visit '/'
      login_as_database_user

      update_meta_key_label 'License'
      visit '/api/browser/'
      wait_until { first('input#url') }
      first('input#url').set '/api/meta-keys/copyright:license'
      find('button#get').click
      expect(json_data['label']).to eq 'License'

      update_meta_key_label 'Copyright-Status'
      visit '/api/browser/'
      wait_until { first('input#url') }
      first('input#url').set '/api/meta-keys/copyright:license'
      find('button#get').click
      expect(json_data['label']).to eq 'Copyright-Status'
    end
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

def json_data
  wait_until { first('.source-code') }
  JSON.parse(find('.source-code').text)
end

def collect_vocabulary_labels
  all('.meta-data-summary h3')
    .map(&:text)
end

def collect_meta_key_labels
  all('.meta-data-summary .media-data-title')
    .map(&:text)
end

def collect_context_key_labels
  all('.app-body-content .form-body .form-label')
    .map(&:text)
    .map { |label| label.chomp(' *') }
end

def update_vocabulary_label(new_label)
  visit '/admin/vocabularies/copyright/edit'
  fill_in 'vocabulary[labels][de]', with: new_label
  click_button 'Save' 
end

def update_meta_key_label(new_label)
  visit '/admin/meta_keys/copyright:license/edit'
  fill_in 'meta_key[labels][de]', with: new_label
  click_button 'Save'
end

def update_context_key_label(new_label)
  visit '/admin/contexts/media_content'
  within first('table.edit-context-keys tr[data-id]') do
    click_link 'Edit'
  end
  fill_in 'context_key[labels][de]', with: new_label
  click_button 'Save'
end
