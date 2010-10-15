# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'spec_helper'

describe Contact do
  before(:each) do
    @params = { :name => 'Boris Barroso', :organisation_name => 'ZenIT',
      :email => 'boriscyber@gmail.com', :address => 'Mallasa calle 4', :phone => '2745620', :mobile => '70681101', :tax_number => '3376951' }
    OrganisationSession.set = { :name => "ecuanime", :id => 1 }
    Organisation.stubs(:find).returns( stub(@@stub_model_methods.merge({:id => 1})) )
  end

  #it { should validates_presence_of :ctype }

  it 'should create a valid' do
    Contact.create!(@params)
  end

  it 'should convert the address to br' do
    @params[:address] = "Mallasa\nCalle Nª4\nCalacoto"
    c = Contact.create!(@params)
    c.address.should == "Mallasa<br/>Calle Nª4<br/>Calacoto"
    #c.address.gsub("<br/>", "\n").should  == "Mallasa\nCalle Nª4\nCalacoto"
  end

  #it 'should not allow other values to ctype' do
  #  @params[:ctype] = 'Other'
  #  c = Contact.new(@params)
  #  c.valid?.should == false
  #end

  it 'Organisation id should be 1' do
    c = Contact.create!(@params)
    c.organisation_id.should == 1
  end

end


