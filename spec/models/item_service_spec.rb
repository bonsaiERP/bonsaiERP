# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec_helper'


describe ItemService do
  before(:each) do
    OrganisationSession.set = {:id => 1, :name => 'ecuanime'}
    ItemService.stubs(:create_price => true)
    
    ModStubs.stub_account_type(:id => 10, :account_number => "Service")
    
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

  it "should not access account if item it's not a service" do
    is = Item.new_item(@params.merge(:ctype => 'product'))
    is.save.should == true

    expect { is.account }.to raise_error( NoMethodError )
  end
end
