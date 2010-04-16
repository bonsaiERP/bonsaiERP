#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tax do
  before(:each) do
    @params = {:name => "Impuesto al valor agregado", :abbreviation => "IVA", :rate => 13.0}
    OrganisationSession.stubs(:organisation_id).returns(1)
    
    Organisation.stubs(:find).returns( stub(@@spec_model_methods.merge({:id => 1})) )
  end

  it 'should create an instance' do
    Tax.create!(@params)
  end

  it 'should set the organisation_id' do
    OrganisationSession.stubs(:organisation_id).returns(3)
    tax = Tax.create!(@params)
    tax.organisation_id.should == 3
  end

end
