require 'spec_helper'

feature 'MediaEntry' do
  scenario 'Up- and download' do
    clean_results = ['DELETE FROM meta_data;',
                     'DELETE FROM zencoder_jobs;',
                     'DELETE FROM media_files;',
                     'DELETE FROM edit_sessions;',
                     'DELETE FROM collections;',
                     'DELETE FROM filter_sets;',
                     'DELETE FROM media_entries;'].map do|cmd|
      Helpers::ConfigurationManagement.invoke_sql cmd
    end

    visit '/'
    expect(page).to have_content 'Media Archive'
    find('input#login').set 'adam'
    find('input#password').set 'password'
    find('form#login_form').find('[type=submit]').click
    expect(page).to have_content 'Sie haben sich angemeldet.'

    within('.ui-body-title-actions') do
      find('.button-primary').click
    end

    expect(current_path).to eq '/entries/new'

    visit('/entries/new?nojs=1')

    # select file and submit
    within('.app-body') do
      attach_file('media_entry_media_file',
                  File.absolute_path('../api/datalayer/spec/data/images/grumpy_cat.jpg'))
      find("*[type='submit']").click
    end

    within('#app') do
      alert = find('.ui-alert.warning')
      expect(alert).to have_content 'Entry is not published yet!'
    end

    click_on 'Publish!'

    accept_prompt
  end
end
