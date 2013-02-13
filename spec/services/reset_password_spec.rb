# encoding: utf-8
require 'spec_helper'

describe ResetPassword do
  let(:user) { build :user, id: 2 }

  it "update" do
    User.stub_chain(:active, where: [user] )
    user.stub(save: true)
    user.reset_password_token.should_not be_present
    user.reset_password_sent_at.should_not be_present

    ResetPasswordMailer.should_receive(:send_reset_password).and_return(stub(deliver: true))
    rp = ResetPassword.new(email: 'test@mail.com')
    rp.reset_password.should be_true
    
    user.reset_password_token.should be_present
    user.reset_password_sent_at.should be_present
  end

  it "returns error when invalid email" do
    rp = ResetPassword.new(email: 'jajaj')

    rp.reset_password.should be_false
    rp.errors[:email].should eq([I18n.t('errors.messages.user.email_not_found')])

  end

  it "updates password" do
    user.should_receive(:save).and_return(true)
    user.change_default_password = false

    rp = ResetPassword.new
    rp.reset_password(user).should be_true

    user.should be_change_default_password
  end
end
