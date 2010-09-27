require 'spec_helper'

describe Contact do
  before(:each) do
    @params = { :name => 'Boris Barroso', :email => 'boriscyber@gmail.com', :address => 'Mallasa calle 4', :phone => '2745620', :mobile => '70681101', :tax_number => '3376951', :ctype => Contact::TYPES.first }
    OrganisationSession.set = { :name => "ecuanime", :id => 1 }
    Organisation.stubs(:find).returns( stub(@@stub_model_methods.merge({:id => 1})) )
  end

  #it { should validates_presence_of :ctype }

  it 'should create a valid' do
    Contact.create!(@params)
  end

  it 'should not allow other values to ctype' do
    @params[:ctype] = 'Other'
    c = Contact.new(@params)
    c.valid?.should == false
  end

  it 'Organisation id should be 1' do
    c = Contact.create!(@params)
    c.organisation_id.should == 1
  end

end


