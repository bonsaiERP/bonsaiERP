# encoding: utf-8
class ResetPasswordMailer < ActionMailer::Base
  default from: "#{APP_NAME} <noresponder@#{DOMAIN}>"

  layout "email"

  # Sends the registration email to the contact
  def send_reset_password(user)
    @user = user
    @host = ActionMailer::Base.default_url_options[:host]
    mail(to: @user.email, subject: I18n.t("email.reset_password.subject", app_name: APP_NAME))
  end
end
