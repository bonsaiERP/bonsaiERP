#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Unit do

  before(:each) do
    OrganisationSession.set :id => 1
    @params = {:name => "kilogram", :symbol => "kg", :integer => false}
  end


  it 'should create an instance' do
    Unit.create!(@params)
  end

  it 'should validate uniqueness' do
    u = Unit.create!(@params)
    u = Unit.new(@params)

    u.should_not be_valid
    u.organisation_id.should == OrganisationSession.organisation_id
    u.errors[:name].should_not be_blank
    u.errors[:symbol].should_not be_blank
  end

end
