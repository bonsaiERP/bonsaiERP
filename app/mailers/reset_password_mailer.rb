class ResetPasswordMailer < ActionMailer::Base
  default :from => "noresponder@bonsaierp.com"

  layout "email"

  # Sends the registration email to the contact
  def send_reset_password(user)
    @user = user
    @host = ActionMailer::Base.default_url_options[:host]
    mail(:to => @user.email, :subject => I18n.t("bonsai.reset_password"))
  end
end
