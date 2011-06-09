# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec_helper'

describe Supplier do
  before(:each) do
    OrganisationSession.set = {:id => 1, :name => 'ecuanime'}
    @params = { :first_name => 'First name', :last_name => 'Last name',
      :address => "Los Pinos Bloque 80\ndpto.201"}

    ModStubs.stub_account_type(:id => 1, :account_number => "Supplier")
  end

  it 'should create a client' do
    Supplier.create!(@params)
  end

  it 'should create an account' do
    s = Supplier.create(@params)

    s.account.should_not == blank?
    s.account.amount.should == 0 
    s.account.initial_amount.should == 0
    s.account.account_type_id.should == 1
  end
    
end


