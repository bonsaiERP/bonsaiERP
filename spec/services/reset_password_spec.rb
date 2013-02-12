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

  it "updates password"
end
