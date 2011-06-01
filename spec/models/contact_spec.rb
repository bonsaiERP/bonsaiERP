# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'spec_helper'

describe Contact do
  before(:each) do
    @params = { 
      :first_name => 'Boris', :last_name => "Barroso", :organisation_name => 'bonsailabs',
      :email => 'boris@bonsailabs.com', :matchcode => 'Boris Barroso',
      :address => "Los Pinos Bloque 80\nDpto. 202", :phone => '2745620', 
      :mobile => '70681101', :tax_number => '3376951' }

    OrganisationSession.set = { :name => "ecuanime", :id => 1 }
    #Organisation.stubs(:find).returns( stub(@@stub_model_methods.merge({:id => 1})) )
  end

  #it { should validates_presence_of :ctype }

  it 'should create a valid' do
    Client.create!(@params)
  end

  it 'should set the organisation id' do
    OrganisationSession.stubs(:organisation_id => 100)
    c = Client.create(@params)

    c.persisted?.should == true
    c.organisation_id.should == 100
    c.active.should == true
  end

  it 'should create a new account' do
    
  end

end


