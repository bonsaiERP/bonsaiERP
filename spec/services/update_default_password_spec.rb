require 'spec_helper'

describe UpdateDefaultPassword do

  let(:user) { build :user, id: 10 }
  let(:attributes) { { password: 'DEMO1234', password_confirmation: 'DEMO1234', user: user } }

  it "valid user" do
    up = UpdateDefaultPassword.new(password: 'demo1234', user: nil, password_confirmation: 'demo1234')
    up.should_not be_valid

    up.errors.messages[:user].should_not be_blank
  end

  it "validation" do
    up = UpdateDefaultPassword.new(password: 'demo1234', user: user)
    up.should_not be_valid

  end

  it "update_default_password" do
    user.stub(save: true)
    up = UpdateDefaultPassword.new(attributes)

    up.update_password.should eq(true)

    user.should be_valid_password('DEMO1234')
    user.should_not be_change_default_password
  end

end
