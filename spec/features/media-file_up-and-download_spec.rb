require 'spec_helper'

# NOTE: UI strings are hardcoded on purpose, working strings are part of test!
# Needs to be updated when translations.csv changes in `webapp`!

GRUMPY_CAT_PATH= File.absolute_path('../api/datalayer/spec/data/images/grumpy_cat.jpg')

feature 'MediaEntry Up- and download.' do

  scenario 'Upload a Media-Entry in the UI and publish it. ' \
    << 'Access the API, follow the links to the corresponding Media-File. ' \
    << 'Download the Media-File via the API in a complete piece and in parts. ' \
    << 'Verify that the downloaded file is identical to the uploaded file.' do
    clean_results = ['DELETE FROM meta_data;',
                     'DELETE FROM zencoder_jobs;',
                     'DELETE FROM media_files;',
                     'DELETE FROM edit_sessions;',
                     'DELETE FROM collections;',
                     'DELETE FROM filter_sets;',
                     'DELETE FROM media_entries;',
                     'DELETE FROM context_keys'].map do|cmd|
      Helpers::ConfigurationManagement.invoke_sql cmd
    end

    visit '/'
    expect(page).to have_content 'Media Archive'
    login_as_database_user
    expect(page).to have_content 'Sie haben sich angemeldet.'

    within('.ui-body-title-actions') do
      find('.button-primary', text: 'Medien importieren').click
    end

    expect(current_path).to eq '/my/upload'

    visit('/my/upload?nojs=1')

    # select file and submit
    within('.app-body') do
      attach_file('media_entry_media_file', GRUMPY_CAT_PATH)
      find("*[type='submit']").click
    end

    # within('#app') do
    #   alert = find('.ui-alert.warning')
    #   expect(alert)
    #     .to have_content 'Dieser Medieneintrag ist noch nicht gesichert!'
    # end
    #
    # click_on 'Speichern'
    # 
    # accept_prompt

    visit('/api/browser/index.html')
    api_click_on_relation_method 'media-entries', 'GET'
    within('.modal-footer') { click_on 'GET' }
    api_click_on_relation_method '1', 'GET'
    api_click_on_relation_method 'media-file', 'GET'
    api_click_on_relation_method 'data-stream', 'GET'
    expect(page).to have_content "200 OK"

    # Download via API
    data_stream_path = find('input#url').value
    url = Capybara.app_host + data_stream_path
    buffer = `curl -u adam:password #{url}`
    digest_original= Digest::SHA1.file(GRUMPY_CAT_PATH).hexdigest
    digest_download= Digest::SHA1.hexdigest(buffer)
    expect(digest_download).to be== digest_original


    # PARTIAL DL via API
    partial_digest= Digest::SHA1.new
    partial_digest.update `curl -r 0-999 -u adam:password #{url}`
    partial_digest.update `curl -r 1000- -u adam:password #{url}`
    expect(partial_digest.hexdigest).to be== digest_original
  end
end
