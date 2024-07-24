require 'mail'

MADEK_MAIL_SMTP_PORT = ENV.fetch('MADEK_MAIL_SMTP_PORT','25')
MADEK_MAIL_DIR = ENV['MADEK_MAIL_DIR'] || '../mail'
FAKE_MAILBOX_DIR = "#{MADEK_MAIL_DIR}/tmp/fake-mailbox"

RSpec.configure do |config|
  config.before :suite do
    setup_email_client
  end
  config.before :each do |example|
    empty_mailbox
  end
end

private

def setup_smtp_port
  SmtpSetting.first.update(port: MADEK_MAIL_SMTP_PORT)
  sleep 1.1 # due to memoized smtp settings in the mail app
end

def empty_mailbox
  Mail.delete_all
  system("rm -rf #{FAKE_MAILBOX_DIR}/*")
end

def setup_email_client
  $mail ||= Mail.defaults do
    retriever_method(:pop3,
                     address: ENV.fetch('MADEK_MAIL_SMTP_ADDRESS', 'localhost'),
                     port: ENV.fetch('MADEK_MAIL_POP3_PORT', '110'),
                     user_name: 'any',
                     password: 'any',
                     enable_ssl: false)
  end
end
