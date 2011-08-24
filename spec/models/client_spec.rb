# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec_helper'

describe Client do
  before(:each) do
    OrganisationSession.set = {:id => 1, :name => 'ecuanime', :currency_id => 1}
    @params = { :first_name => 'First name', :last_name => 'Last name',
      :matchcode => "Boris Barroso",
      :address => "Los Pinos Bloque 80\ndpto.201"}

    ModStubs.stub_account_type(:id => 1, :account_number => "Client")
    AccountType.stubs(:org => stub(:find_by_account_number => stub(:id => 2), :account_number => "Client"))
  end

  it 'should create a client' do
    Client.create!(@params)
  end

  it 'should set the original type for account' do
    c = Client.create!(@params)
    c.accounts.size.should == 1
    c.accounts.first.original_type.should == "Client"
  end

  it 'should assing the correct currency' do
    c = Client.create!(@params)
    c.accounts.first.currency_id.should == 1
  end

  it 'should give the correct currency' do
    c = Client.create!(@params.merge(:currency_id => 3))

    c.accounts.first.currency_id.should == 1
  end
    
end

