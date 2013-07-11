# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationMailer < ActionMailer::Base
  default from: %Q("#{APP_NAME}" <register@#{DOMAIN}>)

  layout "email"

  # Sends the registration email to the contact
  def send_registration(reg)
    @user = reg.user
    @tenant = reg.tenant
    to = [reg.email, 'boris@bonsaierp.com']

    mail(to: to, subject: I18n.t("email.registration.send", app_name: APP_NAME, email: reg.email) )
  end

  def user_registration(reg)
    @user = reg.user
    @tenant = OrganisationSession.tenant
    @name = OrganisationSession.name

    mail(to: "\"#{@user}\" <#{@user.email}>", subject: I18n.t("email.registration.user", app_name: APP_NAME, company: @name) )
  end

  def test_email(reg)
    mail(to: "\"#{reg.name}\" <#{reg.email}>", subject: "Email desde #{APP_NAME}")
  end
end
