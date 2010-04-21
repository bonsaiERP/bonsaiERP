#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tax do
  before(:each) do
    @params = {:name => "Impuesto al valor agregado", :abbreviation => "IVA", :rate => 13.0}
    OrganisationSession.stubs(:id => 1, :name => 'ecuanime')
    
    Organisation.stubs(:find).returns( stub(@@spec_model_methods.merge({:id => 1})) )
  end

  it 'should create an instance' do
    Tax.create!(@params)
  end

  it 'should set the organisation_id' do
    OrganisationSession.stubs(:id).returns(3)
    tax = Tax.create!(@params)
    tax.organisation_id.should == 3
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
    Item.all.size.should == 2
  end

  # Not UNIT TEST
  it 'should create a unit' do
    tax = Tax.create!(@params)
    @params[:name] = "Impuesto a las transacciones"
    tax = Tax.create!(@params)
    Unit.invisible.size.should == 1
  end


end
