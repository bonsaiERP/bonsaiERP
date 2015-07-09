# encoding: utf-8
require 'spec_helper'

describe ResetPasswordEmail do
  let(:user) { build :user, id: 2 }

  it "send ResetPasswordEmailMailer" do
    User.stub_chain(:active, where: [user] )
    user.stub(save: true, active_links: [build(:link, active: true, tenant: 'bonsai')])
    PgTools.stub(schema_exists?: true)
    user.reset_password_token.should_not be_present
    user.reset_password_sent_at.should_not be_present

    ResetPasswordMailer.should_receive(:send_reset_password).and_return(double(deliver: true))
    rp = ResetPasswordEmail.new(email: 'test@mail.com')
    rp.reset_password.should eq(true)

    user.reset_password_token.should be_present
    user.reset_password_sent_at.should be_present
  end

  it "sends RegistrationMailer" do
    User.stub_chain(:active, where: [user] )
    user.stub(save: true, active_links: [build(:link, active: true, master_account: true)])
    PgTools.stub(schema_exists?: false)

    #
    user.reset_password_token.should_not be_present
    user.reset_password_sent_at.should_not be_present

    RegistrationMailer.should_receive(:send_registration).and_return(double(deliver: true))

    rp = ResetPasswordEmail.new(email: 'test@mail.com')
    rp.reset_password.should eq(true)

    user.reset_password_token.should be_present
    user.reset_password_sent_at.should be_present
  end

  it "returns false" do
    User.stub_chain(:active, where: [user] )
    user.stub(save: true, active_links: [build(:link, active: true, master_account: false)])

    rp = ResetPasswordEmail.new(email: 'test@mail.com')
    rp.reset_password.should eq(false)
  end

  it "returns error when invalid email" do
    rp = ResetPasswordEmail.new(email: 'jajaj')

    rp.reset_password.should eq(false)
    rp.errors[:email].should eq([I18n.t('errors.messages.user.email_not_found')])

  end

end
