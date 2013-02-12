require 'spec_helper'

describe UserPassword do
  let(:user) { build :user, id: 10 }
  before(:each) do
    UserSession.user = user
  end

  it "sets errors" do
    user.stub(valid_password?: true)
    up = UserPassword.new(password: 'demo123', password_confirmation: 'demo123', old_password: 'demo123')

    up.update_password.should be_false
    up.errors[:password].should_not be_blank
  end

  context "update_password" do
    it "valid old_password" do
      user.should_receive(:save).and_return(true)

      user.stub(:valid_password?).with('demo1234').and_return(true)

      up = UserPassword.new(password: 'Demo1234', password_confirmation: 'Demo1234', old_password: 'demo1234')
      up.user = user

      up.update_password.should be_true
    end

    it "invalid old_password" do
      user.stub(:valid_password?).with('jaja').and_return(false)

      up = UserPassword.new(password: 'Demo1234', password_confirmation: 'Demo1234', old_password: 'jaja')
      up.user = user

      up.update_password.should be_false
      up.errors[:old_password].should_not be_blank
    end
  end

  context 'update_default_password' do
    it "update_default_password" do
      user.should_receive(:save).and_return(true)
      user.change_default_password = false
      user.should_not be_change_default_password

      up = UserPassword.new(password: 'Demo1234', password_confirmation: 'Demo1234')
      up.user = user

      up.update_default_password.should be_true
      up.should_not be_change_default_password
    end
  end

  context 'update_reset_password' do
    it "does" do
      user.should_receive(:save).and_return(true)
      user.change_default_password = false
      user.should_not be_change_default_password

      up = UserPassword.new(password: 'Demo1234', password_confirmation: 'Demo1234')
      up.user = user

      up.update_reset_password.should be_true
      up.should_not be_change_default_password
    end
  end

end
