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

    a.account_number.should == "test"
    a.active.should == true
    a.organisation_id.should == 1
  end

  it 'should not assign organisation_id' do
    @params = @params.merge(:organisation_id => 1)

    a = AccountType.create(@params)
    
    a.organisation_id.should == 1

    a.organisation_id = 2
    a.save
    a.reload

    a.organisation_id.should == 1
  end

  it 'should not destroy' do
    a = AccountType.create(@params) {|a| a.account_number = @params[:account_number]}
    
    a.account_number.should == @params[:account_number]
    a.persisted?.should == true

    a.destroy
    a.destroyed?.should == false
    a.active.should == false
  end

  it 'should look only account created with the current session' do
    AccountType.create(@params)
    OrganisationSession.set :id => 2
    AccountType.create(@params)

    AccountType.all.size.should == 2
    OrganisationSession.organisation_id.should == 2
    AccountType.org.size.should == 1
  end
end
