#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Item do
  before(:each) do
    OrganisationSession.set = {:id => 1, :name => 'ecuanime'}
    @params = { :name => 'First item', :unit_id => 1, :code => 'AU101' }
    Unit.stubs(:find).returns(stub(@@stub_model_methods.merge(:id => 1) ) )
  end

  it 'should create an item' do
    Item.create!(@params)
  end

  it 'should be set organisation_id' do
    item = Item.create(@params)
    item.organisation_id.should == 1
  end

  it 'should not save if price is not set and product is set' do
    @params[:product] = true
    item = Item.new(@params)
    item.valid?.should == false
  end

  it 'should assing discount a value of 0' do
    @params[:product] = true
    @params[:price] = 25.00
    item = Item.create!(@params)
    item.discount.should == 0
  end

  it 'price should be greater or equal to 0' do
    @params[:product] = true
    @params[:price] = -0.1
    item = Item.new(@params)
    item.valid?.should == false
  end

  it 'discount should be between 0 and 100' do
    @params[:product] = true
    @params[:price] = 25
    @params[:discount] = -1
    item = Item.new(@params)
    item.valid?.should == false
    item.discount = 101
    item.valid?.should == false
  end

  #it "shouldn't make an invisible item" do
  #  @params[:visible] = false
  #  item = Item.create(@params)
  #  Item.invisible.size.should == 0
  #end

  #it "should make an invisible item" do
  #  item = Item.new(@params)
  #  item.visible = false
  #  item.save
  #  Item.invisible.size.should == 1
  #end

  #it 'should return all visible and invisible records' do
  #  Item.create!(@params)
  #  item = Item.new(@params)
  #  item.visible = false
  #  item.save
  #  Item.all_records.size.should == 2
  #  Item.invisible.size.should == 1
  #  Item.all.size.should == 1
  #end
end
