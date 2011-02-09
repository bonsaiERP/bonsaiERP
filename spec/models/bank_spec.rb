require 'spec_helper'

describe Bank do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime')

    @params = {:currency_id => 1, :total_amount => 10000, :name => 'Banco 1', :number => '12365498'}
  end

  it 'should create an instance' do
    Bank.create!(@params)
  end

  # NOT unit test
  it 'should create a ledger if amount is greater than 0' do
    b = Bank.create!(@params)
    b.account_ledgers.size.should == 1
    b.account_ledgers.first.amount.should == b.total_amount
  end

  # NOT test unit
  it 'should not create ledger if amount is 0' do
    params = @params.merge(:total_amount => 0)
    b = Bank.create!(params)
    b.account_ledgers.size.should == 0
  end
end

