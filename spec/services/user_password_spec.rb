require 'spec_helper'

describe UserPassword do
  context "Password" do
    it "checks password" do
      u = User.new(email: 'test@mail.com', password: 'demo1234')

      u.should_not be_valid
      u.errors_on(:password).should_not be_blank

      u.password_confirmation = 'demo1234'
      u.save.should be_true

      # Update password
      u = User.find(u.id)
      u.password = 'Demo1234'
      u.should_not be_valid

      u.errors_on(:password).should_not be_blank
    end

    it "checks the old password" do
      u = User.create!(email: 'test@mail.com', password: 'demo1234', password_confirmation: 'demo1234')

      u.should_not be_change_default_password

      u.should be_valid_password('demo1234')
      u = User.find(u.id)

      u.update_password({password: 'Demo1234', password_confirmation: 'Demo1234'}).should be_false
      # Need to user API this way because errors_on doesn't work
      u.errors.messages[:old_password].should eq([I18n.t('errors.messages.invalid')])

      # check assigns
      u.password.should eq('Demo1234')
      u.password_confirmation.should eq('Demo1234')

      # Update
      u = User.find(u.id)
      u.update_password({old_password: 'demo1234', password: 'Demo1234', password_confirmation: 'Demo1234'}).should be_true

      u = User.find(u.id)
      u.should be_valid_password('Demo1234')
    end

    it "should change change_default_password" do
      u = User.create!(email: 'test@mail.com', password: 'demo1234', password_confirmation: 'demo1234', change_default_password: true)

      u.should be_change_default_password

      u = User.find(u.id)

      u.update_password(password: 'Demo1234', password_confirmation: 'Demo1234').should be_true

      u.should_not be_change_default_password
    end
  end
end
