class ApplicationMailer < ActionMailer::Base
  default from: ENV['MJ_SEND_MAIL']
  layout 'mailer'
end
