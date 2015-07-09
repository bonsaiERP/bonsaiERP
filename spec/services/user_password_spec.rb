require 'spec_helper'

describe UserPassword do
  let(:user) { create :user, id: 10, password: 'demo1234' }
  before(:each) do
    UserSession.user = user
  end

  it "sets errors" do
    up = UserPassword.new(password: 'demo123', old_password: 'demo123')

    up.update_password.should eq(false)
    up.errors[:password].should_not be_blank
  end

  context "update_password" do
    it "valid old_password" do
      user.reset_password_token.should be_blank

      up = UserPassword.new(password: 'Demo1234', old_password: 'demo1234')
      up.user = user

      up.update_password.should eq(true)
    end

    it "invalid old_password" do
      user.stub(:valid_password?).with('jaja').and_return(false)

      up = UserPassword.new(password: 'Demo1234', old_password: 'jaja')
      up.user = user

      up.update_password.should eq(false)
      up.errors[:old_password].should_not be_blank
    end
  end

end
