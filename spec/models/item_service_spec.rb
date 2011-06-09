# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec_helper'


describe ItemService do
  before(:each) do
    OrganisationSession.set = {:id => 1, :name => 'ecuanime'}
    ItemService.stubs(:create_price => true)
    
    a = AccountType.new(:name => "service") {|a| 
      a.id = 10
      a.account_number = "Service"
    }
    fake = Object.new
    fake.stubs(:scoped_by_account_number).with("Service").returns([a])
    AccountType.stubs(:org => fake)

    @params = { :name => 'First item', :unit_id => 1, :unitary_cost => 10, :code => 'AU101', :price => 12, :ctype => "service" }
    Unit.stubs(:find => Unit.new {|u| u.id = 1} )

  end

  it 'should create an item' do
    is = Item.new_item(@params)

    is.save.should == true
    is.reload

    is.account.should_not == blank?
    is.account.amount.should == 0 
    is.account.initial_amount.should == 0
    is.account.account_type_id.should == 10
  end
end
