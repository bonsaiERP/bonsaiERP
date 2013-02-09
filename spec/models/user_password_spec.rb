require 'spec_helper'

describe UserPassword do
  let(:user) { build :user, id: 10 }


  context "normal_password" do
    it "wrong old password" do
      user.should_receive(:save).and_return(true)

      user.change_default_password = false
      user.should_not be_change_default_password

      user.stub(:valid_password?).with('jaja').and_return(false)

      up = UserPassword.new({password: 'Demo1234', password_confirmation: 'Demo1234', old_password: 'demo1234', old_password: 'jaja'})
      up.user = user

      up.update_password.should be_false
      up.errors.messages[:old_password].should eq([I18n.t('errors.messages.invalid')])

      # Change default password
      user.stub(:valid_password?).with('demo1234').and_return(true)

      up = UserPassword.new({password: 'Demo1234', password_confirmation: 'Demo1234', old_password: 'demo1234', old_password: 'demo1234'})
      up.user = user

      up.update_password.should be_true
    end
  end

  context 'update_default_password' do
    it "update_default_password" do
      user.should_receive(:save).and_return(true)

      user.change_default_password = true
      user.should be_change_default_password

      up = UserPassword.new({password: 'Demo1234', password_confirmation: 'Demo1234'})
      up.user = user

      up.update_password.should be_true
      up.should_not be_change_default_password
    end
  end

  context 'update_reset_password' do
    it "does" do
      user.should_receive(:save).and_return(true)

      user.change_default_password = true
      user.should be_change_default_password

      up = UserPassword.new({password: 'Demo1234', password_confirmation: 'Demo1234'})
      up.user = user

      up.update_reset_password.should be_true
      up.should_not be_change_default_password
    end
  end

end
