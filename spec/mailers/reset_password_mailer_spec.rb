require "spec_helper"

describe ResetPasswordMailer do
  let(:user) {
    User.new(:email => "demo@example.com") {|u|
      u.confirmation_token = SecureRandom.base64(12)
      u.id = 1
    }
  }

  it 'should send the password' do
    ResetPasswordMailer.send_reset_password(user).deliver

    ActionMailer::Base.deliveries.should_not be_empty

    mail = ActionMailer::Base.deliveries.first
    mail.subject.should == I18n.t("bonsai.reset_password")
    mail.to.should == [user.email]

    #mail.encoded.should =~ /Recuperación de contraseña/
    mail.encoded.should =~ /\/reset_passwords\/#{user.id}\/edit/

  end
end
