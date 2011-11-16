require 'spec_helper'

describe AccountType do
  before(:each) do
    @params = {:name => 'Test', :account_number => 'test'}
  end

  it 'should create a new' do
    AccountType.create!(@params)
  end

  it 'should not assing account_number' do
    a = AccountType.create(@params)

    a.account_number.should == "test"
  end

  it 'should not destroy' do
    a = AccountType.create(@params) {|a| a.account_number = @params[:account_number]}
    
    a.account_number.should == @params[:account_number]
    a.persisted?.should == true

    a.destroy
    a.destroyed?.should == false
  end

  it 'should look only account created with the current session' do
    AccountType.create(@params)
    OrganisationSession.set :id => 2
    AccountType.create(@params)

    AccountType.all.size.should == 2
  end

  it 'should create many account_types' do
    AccountType.count.should == 0
    AccountType.create_base_data
    AccountType.count.should > 2
  end
end
