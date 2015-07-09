require 'spec_helper'

describe ResetPassword do
  it { should_not have_valid(:password).when('demo214', 'sim3') }

  it '#validates' do
    rp = ResetPassword.new(password: 'demo1234')
    rp.stub(user: build(:user))
    rp.should_not be_valid

    rp.errors.messages[:password].should eq([I18n.t('errors.messages.confirmation')])
    rp.password_confirmation = 'demo1234'

    rp.should be_valid
  end

  it "#check time ago" do
    token = SecureRandom.urlsafe_base64
    create(:user, email: 'juan@mail.com', reset_password_token: token, reset_password_sent_at: 2.hours.ago)

    rp = ResetPassword.new(user: nil, password: 'DEMO1234', password_confirmation: 'DEMO1234')
    rp.update_password.should eq(false)

    rp.errors.messages[:user].should eq([I18n.t('errors.messages.blank')])


    User.find_by(reset_password_token: token).should be_is_a(User)
  end

  it "#updates" do
    token = SecureRandom.urlsafe_base64
    u = create(:user, email: 'juan@mail.com', reset_password_token: token, reset_password_sent_at: 15.minutes.ago)

    rp = ResetPassword.new(user: u, password: 'DEMO1234', password_confirmation: 'DEMO1234')
    rp.update_password.should eq(true)

    u.reload
    u.should be_valid_password('DEMO1234')
    u.reset_password_token.should eq('')
  end
end
