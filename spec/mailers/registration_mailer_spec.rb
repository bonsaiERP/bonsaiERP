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

  it '#send_registration' do
    email = RegistrationMailer.send_registration(registration)


    email.subject.should eq(I18n.t("email.registration.send", email: registration.email, app_name: APP_NAME))
 
    email.to.should == [user.email]
    email.from.should eq(["register@#{DOMAIN}"])

    header  = email.header.to_s
    header.should =~ /From: #{APP_NAME} <register@#{DOMAIN}>/
    header.should =~ /To: #{user} <demo@example.com>/

    link = "http://#{tenant}.#{DOMAIN}/registrations/#{user.confirmation_token}"
    email.body.should have_selector("a[href='#{link}']")
  end

  it "#user_registration" do
    OrganisationSession.organisation =  build :organisation, name: 'Club Vegetariano', tenant: 'clubv'

    email = RegistrationMailer.user_registration(registration)


    email.subject.should eq(I18n.t("email.registration.user", app_name: APP_NAME, company: 'Club Vegetariano'))
 
    email.to.should == [user.email]
    email.from.should eq(["register@#{DOMAIN}"])


    prot = UrlTools.protocol
    link = "#{prot}://clubv.#{DOMAIN}/registrations/#{user.confirmation_token}/new_user"
    email.body.should have_selector("a[href='#{link}']")

    email.body.should have_text("a sido adicionado para formar parte del equipo de Club Vegetariano")
  end
end
