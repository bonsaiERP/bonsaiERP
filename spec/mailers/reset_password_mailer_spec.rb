# encoding: utf-8
require "spec_helper"

describe ResetPasswordMailer do
  let(:user) {
    User.new(:email => "demo@example.com") {|u|
      u.reset_password_token = SecureRandom.urlsafe_base64(12)
      u.id = 1
    }
  }

  it 'should send the password' do
    ResetPasswordMailer.send_reset_password(user).deliver_now

    ActionMailer::Base.deliveries.should_not be_empty

    mail = ActionMailer::Base.deliveries.first
    mail.subject.should == I18n.t("email.reset_password.subject", app_name: APP_NAME)
    mail.to.should == [user.email]

    url = "#{HTTP_PROTOCOL}://app.#{DOMAIN}/reset_passwords/#{user.reset_password_token}/edit"

    mail.body.should have_selector('h1', text: "Recuperación de contraseña en #{APP_NAME}")
    mail.body.should have_selector("a[href='#{url}']")
  end
end
