#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Contact do
  before(:each) do
    @params = { :name => 'Boris Barroso', :email => 'boriscyber@gmail.com', :address => 'Mallasa calle 4', :phone => '2745620', :mobile => '70681101', :tax_number => '3376951' }
    OrganisationSession.set = { :name => "ecuanime", :id => @@spec_uuid }
    Organisation.stubs(:find).returns( stub(@@spec_model_methods.merge({:id => @@spec_uuid})) )
  end

  it 'should create a valid' do
    Contact.create!(@params)
  end

  # NOT A UNIT TEST
  it 'should create an Item' do
    contact = Contact.create!(@params)
    contact.item.name.should == contact.name
    contact.item.id.should_not nil
    contact.item.unit.should_not nil
  end

  # NOT A UNIT TEST
  it 'should create one Unit if many contacts are created' do
    contact = Contact.create!(@params)
    @params[:name] = "Juan Perez"
    @params[:address] = "San Roque"
    @params[:email] = "juan@example.com"
    contact = Contact.create!(@params)
    Contact.all.size.should > 0
    Unit.invisible.size.should == 1
  end
end
