#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tax do
  before(:each) do
    @params = {:name => "Impuesto al valor agregado", :abbreviation => "IVA", :rate => 13.0}
    OrganisationSession.stubs(:id => @@spec_uuid, :name => 'ecuanime')
    
    Organisation.stubs(:find).returns( stub(@@spec_model_methods.merge({:id => @@spec_uuid})) )
  end

  it 'should create an instance' do
    Tax.create!(@params)
  end

  it 'should set the organisation_id' do
    #OrganisationSession.stubs(:id).returns(3)
    tax = Tax.create!(@params)
    tax.organisation_id.should == @@spec_uuid
  end

  # Not a UNIT TEST
  it 'should create an item' do
    tax = Tax.create!(@params)
    tax.item.name.should == tax.name
  end

  # Not a UNIT TEST
  it 'should create two items' do
    tax = Tax.create!(@params)
    @params[:name] = "Impuesto a las transacciones"
    tax = Tax.create!(@params)
    Item.invisible.size.should == 2
  end

  # Not UNIT TEST
  it 'should create a unit when two taxes area created' do
    tax = Tax.create!(@params)
    @params[:name] = "Impuesto a las transacciones"
    tax = Tax.create!(@params)
    OrganisationSession.stubs(:id).returns(@@spec_uuid)
    Unit.invisible.size.should == 1
  end
  
  # NOt UNIT TEST
  it 'should update the item name' do
    tax = Tax.create!(@params)
    tax.name = "Updated tax name"
    tax.save
    tax.item.name.should == "Updated tax name"
    tax.item.valid?.should == true
  end


end
