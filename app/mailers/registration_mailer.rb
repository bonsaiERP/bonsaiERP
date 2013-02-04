# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationMailer < ActionMailer::Base
  default from: %Q("#{APP_NAME}" <register@#{DOMAIN}>)

  layout "mail"

  # Sends the registration email to the contact
  def send_registration(reg)
    @user = reg.user
    @tenant = reg.tenant

    mail(to: reg.email, subject: I18n.t("bonsai.registration", domain: DOMAIN) )
  end
end
