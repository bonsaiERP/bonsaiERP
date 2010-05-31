#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Transaction do
  before(:each) do
    @params = {  }
    OrganisationSession.set = { :name => "ecuanime", :id => @@spec_uuid }
    Organisation.stubs(:find).returns( stub(@@spec_model_methods.merge({:id => @@spec_uuid})) )
  end

  it 'should create an instance' do
    
  end
end
