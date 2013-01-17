require "spec_helper"

describe RegistrationMailer do
  let(:user) {
    build :user, email: 'demo@example.com', confirmation_token: SecureRandom.base64(12)
  }

  let(:registration) do 
    r = Registration.new(email: user.email, tenant: 'bonsai')
    r.stub(user: user)
    r
  end
  let(:tenant) { registration.tenant }

  it 'should send and email to the user' do
    email = RegistrationMailer.send_registration(registration)


    email.subject.should eq(I18n.t("bonsai.registration", domain: DOMAIN))
 
    email.to.should == [user.email]
    email.from.should eq(["register@#{DOMAIN}"])


    link = "http://#{tenant}.#{DOMAIN}/registrations/#{user.confirmation_token}"
    email.body.should have_selector("a[href='#{link}']")
  end
end
