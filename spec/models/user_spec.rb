require 'spec_helper'

describe User do
  before(:each) do
  end

  it 'should return full name' do
    @user = User.new(:first_name => "Boris", :last_name => "Barroso Camberos")
    @user.to_s.should == %Q(#{@user.first_name} #{@user.last_name})
  end
end
