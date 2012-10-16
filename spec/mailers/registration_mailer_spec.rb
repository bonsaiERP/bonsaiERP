require "spec_helper"

describe RegistrationMailer do
  let(:user) {
    User.new(:email => "demo@example.com") {|u|
      u.confirmation_token = SecureRandom.base64(12)
      u.id = 1
    }
  }

  let(:tenant) { 'tenant' }

  it 'should send and email to the user' do
    email = RegistrationMailer.send_registration(user, tenant)


    email.subject.should eq(I18n.t("bonsai.registration", domain: DOMAIN))
 
    email.to.should == [user.email]
    email.from.should eq(["register@#{DOMAIN}"])


    link = "http://#{tenant}.#{DOMAIN}/registrations/#{user.confirmation_token}"
    email.body.should have_selector("a[href='#{link}']")

    #ActionMailer::Base.deliveries.should_not be_empty
    #email = ActionMailer::Base.deliveries.first
  end
end
