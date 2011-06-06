require 'spec_helper'

describe Bank do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)

    @params = {:currency_id => 1, :name => 'Banco 1', :number => '12365498', :address => 'Uno'}

    YAML.load_file( File.join(Rails.root, "db/defaults/account_types.#{I18n.locale}.yml") ).each do |y|
      a = AccountType.new(y)
      a.organisation_id = 1
      a.account_number = y[:account_number]
    end
  end

  it 'should create an instance' do
    Bank.create!(@params)
  end

  it 'should check it is bank' do
    b = Bank.create(@params)
    b.bank?.should == true
    b.cash?.should == false
  end

  it 'should create a bank account' do
    b = Bank.create(@params)
    b.account.should_not == blank?

    b.account.currency_id.should == b.currency_id
  end
  # NOT unit test
  #it 'should create a ledger if amount is greater than 0' do
  #  b = Bank.create!(@params)
  #  b.account_ledgers.size.should == 1
  #  b.account_ledgers.first.amount.should == b.total_amount
  #end

  ## NOT test unit
  #it 'should not create ledger if amount is 0' do
  #  params = @params.merge(:total_amount => 0)
  #  b = Bank.create!(params)
  #  b.account_ledgers.size.should == 0
  #end
end

