require "spec_helper"

describe RegistrationMailer do
  let(:user) {
    User.new(:email => "demo@example.com") {|u|
      u.confirmation_token = SecureRandom.base64(12)
      u.id = 1
    }
  }

  it 'should send and email to the user' do
    RegistrationMailer.send_registration(user).deliver

    ActionMailer::Base.deliveries.should_not be_empty

    mail = ActionMailer::Base.deliveries.first
    mail.subject.should == I18n.t("bonsai.registration")
    mail.to.should == [user.email]

    mail.encoded.should =~ /Bienvenido a/
    mail.encoded.should =~ /\/registrations\/#{user.id}/
  end
end
