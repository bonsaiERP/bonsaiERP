# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Item do
  before(:each) do
    OrganisationSession.set = {:id => 1, :name => 'ecuanime'}
    @params = { :name => 'First item', :unit_id => 1, :code => 'AU101', :ctype => 'Item'}
    Unit.stubs(:find).returns(stub(@@stub_model_methods.merge(:id => 1) ) )
  end

  it 'should create an item' do
    Item.create!(@params)
  end

  it 'should be set organisation_id' do
    item = Item.create(@params)
    item.organisation_id.should == 1
  end

  it 'should not be valid if ctype is not in Item::TYPES' do
    @params[:ctype] = nil
    item = Item.new(@params)
    item.valid?.should_not == true
    item.ctype = 'Other'
    item.valid?.should_not == true
  end


  it 'should assing discount a value of 0' do
    @params[:product] = true
    @params[:price] = 25.00
    item = Item.create!(@params)
    item.discount.to_f.should == 0
  end

  it 'should assing if the product is stockable' do
    item = Item.create(@params)
    item.stockable.should == true
    item.price = 20
    item.ctype = Item::TYPES.last
    item.save
    item.stockable.should == false
  end

  it 'price should be greater or equal to 2' do
    @params[:price] = -0.1
    @params[:ctype] = Item::TYPES[2]
    item = Item.new(@params)
    item.valid?.should == false
    item.ctype = Item::TYPES[3]
    item.valid?.should == false
  end

  it 'discount should be between 0 and 100' do
    @params[:ctype] = Item::TYPES[1]
    @params[:price] = 25
    @params[:discount] = -1.to_s
    item = Item.new(@params)
    
    item.valid?.should == false
    item.errors[:discount].include?(I18n.t("activerecord.errors.messages.greater_than_or_equal_to", :count => 0)).should == true

    item.discount = 101.to_s
    item.valid?.should == false
    item.errors[:discount].include?(I18n.t("activerecord.errors.messages.less_than_or_equal_to", :count => 100)).should == true
  end

  it 'should be valid with ranges' do
    @params[:ctype] = Item::TYPES[2]
    @params[:price] = 25
    @params[:discount] = "10:5 20:5.5"
    item = Item.new(@params)
    item.valid?.should == true
  end

  it 'should show a list of values for discount' do
    @params[:ctype] = Item::TYPES[2]
    @params[:price] = 25
    @params[:discount] = "10:5 20:5.5"
    item = Item.new(@params)
    item.discount_values.should == [[10.0, 5.0], [20.0, 5.5]]
  end

  it 'should validate a range secuence form minor to greater' do
    @params[:ctype] = Item::TYPES[2]
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
    @params[:ctype] = Item::TYPES[2]
    @params[:price] = 25
    @params[:discount] = "10:5 20:"
    item = Item.new(@params)
    item.valid?.should == false
  end

  it 'should not allow percentages greater than 100' do
    @params[:ctype] = Item::TYPES[2]
    @params[:price] = 25
    @params[:discount] = "10:5 20:100.1"
    item = Item.new(@params)
    p item.errors[:discount]
    item.valid?.should == false
  end

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
