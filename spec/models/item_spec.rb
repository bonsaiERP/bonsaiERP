# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec_helper'

describe Item do
  before(:each) do
    OrganisationSession.set = {:id => 1, :name => 'ecuanime'}
    Item.stubs(:create_price => true)
    @params = { :name => 'First item', :unit_id => 1, :unitary_cost => 10, :code => 'AU101', :price => 12, :ctype => "item" }
    #Unit.stubs(:find).returns(stub(@@stub_model_methods.merge(:id => 1) ) )
    Unit.stubs(:find => Unit.new {|u| u.id = 1} )
  end

  it 'should create an item' do
    Item.create!(@params)
  end

  it 'should be set organisation_id' do
    item = Item.create(@params)
    puts item.errors.keys
    item.organisation_id.should == 1
  end

  it 'should not allow the update of type, ctype' do
    item = Item.create(@params.merge(:ctype => 'product'))
    item.stockable.should == true
    item.price = 20
    item.update_attributes(:ctype => 'service')
    item.reload

    item.ctype.should == 'product'
    item.stockable.should == true
  end

  it 'should update' do
    item = Item.create(@params.merge(:ctype => 'product'))
    
    item.update_attributes(:name => 'second name', :price => 25.5)
    item.reload

    item.name.should == "second name"
    item.price.should == 25.5
  end

  it 'should allow blank value to discount' do
    item = Item.new(@params.merge(:price => 20, :ctype => Item::TYPES[2]) )
    item.valid? == true
  end

  it 'price should be greater or equal to 2' do
    @params[:price] = -0.1
    #@params[:ctype] = Item::TYPES[2]
    item = Item.new(@params)
    item.valid?.should == false
    item.ctype = Item::TYPES[3]
    item.valid?.should == false
  end


  it 'should be valid with ranges' do
    #@params[:ctype] = Item::TYPES[2]
    @params[:price] = 25
    @params[:discount] = "10:5 20:5.5"
    item = Item.new(@params)
    item.valid?.should == true
  end

  it 'should show a list of values for discount' do
    #@params[:ctype] = Item::TYPES[2]
    @params[:price] = 25
    @params[:discount] = "10:5 20:5.5"
    item = Item.new(@params)
    item.discount_values.should == [[10.0, 5.0], [20.0, 5.5]]
  end

  it 'should validate a range secuence form minor to greater' do
    #@params[:ctype] = Item::TYPES[2]
    @params[:price] = 25
    @params[:discount] = "10:5 9:5.5"
    item = Item.new(@params)
    item.valid?.should == false
    # Mantain the same percentage
    item.discount = "10:5 11:5.0"
    item.valid?.should == false
    # Lower percentage
    item.discount = "10:5 11:5.5 15:5 20:6"
    item.valid?.should == false
  end

  it 'should not allow bad discount ranges' do
    #@params[:ctype] = Item::TYPES[2]
    @params[:price] = 25
    @params[:discount] = "10:5 20:"
    item = Item.new(@params)
    item.valid?.should == false
  end

  #it 'should not allow percentages greater than 100' do
  #  #@params[:ctype] = Item::TYPES[2]
  #  @params[:price] = 25
  #  @params[:discount] = "10:5 20:100.1"
  #  item = Item.new(@params)
  #  p item.errors[:discount]
  #  item.valid?.should == false
  #end

  #it 'should save when the item is a service' do
  #  #@params[:ctype] = Item::TYPES.last
  #  @params[:price] = 15.0
  #  @params[:unitary_cost] = 10.0
  #  @params[:discount] = "40:1 80:2 120:3"
  #  Item.create!(@params)

  #  #puts  "Item id: #{item.errors}"
  #  #item.valid?.should == true
  #end

  it 'test range regular expression' do
    reg_num = /([\d]+(\.[\d]+)?)/ 
    reg = Item.reg_discount_range

    !!("10:5.5 20:7.5 " =~ reg).should == true
    !!("10.5:5.5 20:7.5" =~ reg).should == true
    !!("10.5:5.5 20:7 " =~ reg).should == true
    # Just one decimal point for percentage
    !!("10.5:5.5 20.33:7.11 " =~ reg).should == false
    # Just with one decimal percentage and quantity with many
    !!("10.55:5.5 20.33:7.1 " =~ reg).should == true
    # negative numbers are not allowed
    !!("10.5:5.5 -20.33:7.1 " =~ reg).should == false
    # Single value
    !!("10.5:5.5 " =~ reg).should == true
    # Single value
    !!("10.5:5.5" =~ reg).should == true
    # empty string
    !!("" =~ reg).should == false
    !!(" " =~ reg).should == false
  end


end
