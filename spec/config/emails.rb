require 'mail'

MADEK_MAIL_SMTP_PORT = ENV.fetch('MADEK_MAIL_SMTP_PORT','25')

RSpec.configure do |config|
  config.before :suite do
    setup_email_client
  end
  config.before :each do |example|
    empty_mailbox
    SmtpSetting.first.update(is_enabled: true)
    setup_smtp_port
  end
end

private

def setup_smtp_port
  SmtpSetting.first.update(port: MADEK_MAIL_SMTP_PORT)
  sleep 1.1 # due to memoized smtp settings in the mail app
end

def empty_mailbox
  Mail.delete_all
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

def assert_received_email(from: nil, to:, subject: nil)
  wait_until do
    Mail.all.detect do |m|
      (from ? m.from == [from] : true) &&
        (to ? m.to == [to] : true) &&
        (subject ? m.subject.match?(subject) : true)
    end
  end
end
