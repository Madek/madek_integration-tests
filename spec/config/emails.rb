require 'mail'

def smtp_port
  ENV.fetch('MADEK_MAIL_SMTP_PORT','33025')
end

RSpec.configure do |config|
  config.before :suite do
    setup_email_client
  end
  config.before :each do |example|
    empty_mailbox
  end
end

private

def empty_mailbox
  begin
    Mail.delete_all
  rescue
  end
end

def setup_email_client
  $mail ||= Mail.defaults do
    retriever_method(:pop3,
                     address: ENV.fetch('MADEK_MAIL_SMTP_ADDRESS', 'localhost'),
                     port: ENV.fetch('MADEK_MAIL_POP3_PORT', '33110'),
                     user_name: 'any',
                     password: 'any',
                     enable_ssl: false)
  end
end
