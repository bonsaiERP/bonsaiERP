require 'spec_helper'

describe AccountType do
  before(:each) do
    @params = {:name => 'Test', :account_number => 'test'}
    OrganisationSession.set :id => 1
  end

  it 'should create a new' do
    AccountType.create!(@params)
  end

  it 'should not assing account_number' do
    a = AccountType.create(@params)

    a.account_number.should == nil
    a.active.should == true
  end

  it 'should not destroy' do
    a = AccountType.create(@params) {|a| a.account_number = @params[:account_number]}
    
    a.account_number.should == @params[:account_number]
    a.persisted?.should == true

    a.destroy
    a.destroyed?.should == false
    a.active.should == false
  end
end
