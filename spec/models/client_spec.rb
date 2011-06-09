# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec_helper'

describe Client do
  before(:each) do
    OrganisationSession.set = {:id => 1, :name => 'ecuanime'}
    @params = { :first_name => 'First name', :last_name => 'Last name',
      :address => "Los Pinos Bloque 80\ndpto.201"}

    ModStubs.stub_account_type(:id => 1, :account_number => "Client")
  end

  it 'should create a client' do
    Client.create!(@params)
  end

  it 'should create an account' do
    c = Client.create(@params)

    c.account.should_not == blank?
    c.account.amount.should == 0 
    c.account.initial_amount.should == 0
    c.account.account_type_id.should == 1
  end
    
end

