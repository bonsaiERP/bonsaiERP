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
  end

  it 'should create a client' do
    Client.create!(@params)
  end

  it 'should create an account' do
    c = Client.create!(@params)

    c.account.should_not == blank?
    c.account.amount.should == 0 
    c.account.initial_amount.should == 0
    c.account.account_type_id.should == 1

    c.account.amount_currency(1).should == 0
  end

  it 'should create account_currency' do
    c = Client.new(@params)

    c.save.should == true
    c.account.amount_currency(1).should == 0
  end

  it 'should set the to_s method for the account' do
    c = Client.new(@params)

    c.save.should == true
    c.account.to_s.should == c.to_s

    c.matchcode = "Boris Edgar Barroso Camberos"
    c.save.should == true

    c.reload
    c.to_s.should == "Boris Edgar Barroso Camberos"
    c.account.to_s.should == c.to_s
  end
    
end

