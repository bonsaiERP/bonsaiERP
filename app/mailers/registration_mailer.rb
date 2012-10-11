# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationMailer < ActionMailer::Base
  default :from => "noresponder@bonsaierp.com"

  layout "mail"

  # Sends the registration email to the contact
  def send_registration(user)
    @user = user
    mail(:to => @user.email, :subject => I18n.t("bonsai.registration"))
  end
end
