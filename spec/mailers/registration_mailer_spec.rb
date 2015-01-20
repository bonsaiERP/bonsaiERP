require "spec_helper"

describe RegistrationMailer do
  let(:user) {
    build :user, email: 'demo@example.com', confirmation_token: SecureRandom.urlsafe_base64(12)
  }

  let(:registration) do
    OpenStruct.new(user: user, tenant: 'bonsai', email: user.email, organisation: double(tenant: 'bonsai', name: 'bonsaiLabs'))
  end

  it '#send_registration' do
    email = RegistrationMailer.send_registration(registration)

    email.subject.should eq(I18n.t("email.registration.send", app_name: APP_NAME, email: registration.email))

    email.to.should eq([user.email, "boris@bonsaierp.com"])
    email.from.should eq(["register@#{DOMAIN}"])

    header  = email.header.to_s
    header.should =~ /From: #{APP_NAME} <register@#{DOMAIN}>/
    header.should =~ /To: demo@example.com/

    link = "http://bonsai.#{DOMAIN}/registrations/#{user.confirmation_token}"
    email.body.should have_selector("a[href='#{link}']")
  end

  it "#user_registration" do
    OrganisationSession.organisation =  build :organisation, name: 'Club Vegetariano', tenant: 'clubv'

    email = RegistrationMailer.user_registration(registration)


    email.subject.should eq(I18n.t("email.registration.user", app_name: APP_NAME, company: 'bonsaiLabs'))

    email.to.should == [user.email]
    email.from.should eq(["register@#{DOMAIN}"])


    link = "#{HTTP_PROTOCOL}://app.#{DOMAIN}/sign_in"

    email.body.should have_selector("a[href='#{link}']")

    email.body.should have_text("a sido adicionado para formar parte del equipo de bonsaiLabs")
  end
end
