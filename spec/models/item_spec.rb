#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Item do
  before(:each) do
    OrganisationSession.stubs(:id => 1, :name => 'ecuanime')
    @params = { :name => 'First item', :unit_id => 1 }
    Unit.stubs(:find).returns(stub( @@spec_model_methods.merge({ :id => 1 } )) )
  end

  it 'should create an item' do
    Item.create!(@params)
  end

  it 'should be set organisation_id' do
    OrganisationSession.stubs(:id => 4, :name => 'ecuanime')
    item = Item.create!(@params)
    item.organisation_id.should == 4
  end

  it 'should not have invisible items' do
    Item.create!(@params)
    Item.all.size.should == 1
    Item.invisible.size.should == 0
  end

  it "shouldn't make an invisible item" do
    @params[:visible] = false
    item = Item.create(@params)
    Item.invisible.size.should == 0
  end

  it "should make an invisible item" do
    item = Item.new(@params)
    item.visible = false
    item.save
    Item.invisible.size.should == 1
  end

  it 'should return all visible and invisible records' do
    Item.create!(@params)
    item = Item.new(@params)
    item.visible = false
    item.save
    Item.all_records.size.should == 2
    Item.invisible.size.should == 1
    Item.all.size.should == 1
  end
end
