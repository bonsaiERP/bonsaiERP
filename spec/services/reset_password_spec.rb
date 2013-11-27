# encoding: utf-8
require 'spec_helper'

describe ResetPassword do
  let(:user) { build :user, id: 2 }

  it "send ResetPasswordMailer" do
    User.stub_chain(:active, where: [user] )
    user.stub(save: true, active_links: [build(:link, active: true, tenant: 'bonsai')])
    PgTools.stub(schema_exists?: true)
    user.reset_password_token.should_not be_present
    user.reset_password_sent_at.should_not be_present

    ResetPasswordMailer.should_receive(:send_reset_password).and_return(double(deliver: true))
    rp = ResetPassword.new(email: 'test@mail.com')
    rp.reset_password.should be_true

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

    rp = ResetPassword.new(email: 'test@mail.com')
    rp.reset_password.should be_true

    user.reset_password_token.should be_present
    user.reset_password_sent_at.should be_present
  end

  it "returns false" do
    User.stub_chain(:active, where: [user] )
    user.stub(save: true, active_links: [build(:link, active: true, master_account: false)])

    rp = ResetPassword.new(email: 'test@mail.com')
    rp.reset_password.should be_false
  end

  it "returns error when invalid email" do
    rp = ResetPassword.new(email: 'jajaj')

    rp.reset_password.should be_false
    rp.errors[:email].should eq([I18n.t('errors.messages.user.email_not_found')])

  end

end
