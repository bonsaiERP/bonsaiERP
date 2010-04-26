#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationSession do
  before(:each) do
  end

  it 'should allow to be set ussing a Hash' do
    OrganisationSession.set( { :name => 'test', :id => @@spec_uuid } )
    OrganisationSession.id.should == @@spec_uuid
    OrganisationSession.name.should == 'test'
  end

  it 'should allow to be set=' do
    OrganisationSession.set =  { :name => 'test', :id => @@spec_uuid }
    OrganisationSession.id.should == @@spec_uuid
    OrganisationSession.name.should == 'test'
  end

end
