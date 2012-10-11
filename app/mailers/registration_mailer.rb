# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationMailer < ActionMailer::Base
  default :from => "noresponder@#{DOMAIN}"

  layout "mail"

  # Sends the registration email to the contact
  def send_registration(user)
    @user = user
    @port = Rails.env.production? ? 80 : 3000

    mail(:to => @user.email, :subject => I18n.t("bonsai.registration", domain: DOMAIN) )
  end
end
