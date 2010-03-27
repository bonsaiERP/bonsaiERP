#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organisation do
  before(:each) do
#    @country = Country.new(:id => 1, :name => "Bolivia", :abbreviation => "bo", :blank? => true).stubs(:id => 1)
#    Country.stubs(:find).returns(@country)
#
#    @user = User.new(:id => 1, :name => "Juan", :blank? => false)
#    User.stubs(:find).returns(@user)
    @params = {:name => "ecuanime", :user_id => 1,
      :country_id => 1, :address => "Mallasa calle 4 Nº 71",
      :phone => "2745620", :mobile => "70681101",
      :email => "boris@example.com", :website => "ecuanime.net"
    }
  end

  it 'should not allow user to be set' do
    @org = Organisation.create(@params)
    @org.user_id.should == nil
  end

  it 'should only set user_id with set_user' do
    @org = Organisation.new(@params)
    @org.set_user(1)
    @org.valid?.should == true
  end

  it 'should save' do
    @org = Organisation.new(@params)
    @org.set_user(1)
    @org.save.should == true
  end
end
