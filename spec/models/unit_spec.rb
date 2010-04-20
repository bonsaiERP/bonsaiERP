#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Unit do

  before(:each) do
    OrganisationSession.stubs(:organisation_id).returns(1)
    @params = {:name => "kilogram", :symbol => "kg", :integer => false}
  end


  it 'should create an instance' do
    Unit.create!(@params)
  end

  it 'should return yes' do
    @params[:integer] = true
    unit = Unit.create(@params)
    unit.integer?.should == "Yes"
  end

  it 'should return no' do
    unit = Unit.create(@params)
    unit.integer?.should == "No"
  end

  it 'should set default to false for unit' do
    @params.delete(:integer)
    unit = Unit.create(@params)
    unit.integer.should == false
  end

  it 'should set organisation_id' do
    OrganisationSession.stubs(:organisation_id).returns(5)
    unit = Unit.create(@params)
    unit.organisation_id.should == 5
  end
end
