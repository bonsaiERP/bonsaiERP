# encoding: utf-8
require 'spec_helper'

describe AccountLedger do
  let(:params) do
    {
      :date => Date.today, :operation => "out", :reference => "Income", :amount => 100, :currency_id => 1, :exchange_rate => 1,
      :account_id => 2, :to_id => 1
    }
  end


  let!(:currency) do
    Currency.create!(:name => 'Boliviano', :symbol => 'Bs.') {|c| c.id = 1}
  end

  let!(:client_account) do
    Account.create!(
      :name => "Juan perez", :account_type_id => 1, :currency_id => 1,
      :accountable_id => 1, :accountable_type => "Client"
    ) {|a| a.id = 1; a.amount = 0 }
  end

  let!(:bank_account) do
    Account.create!(
      :name => "Bank 1", :account_type_id => 1, :currency_id => 1,
      :accountable_id => 1, :accountable_type => "Bank" 
    ) {|a| a.id = 2; a.amount = 1000}
  end

  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
  end

  it { should have_valid(:operation).when( *AccountLedger::OPERATIONS ) }
  it { should_not have_valid(:operation).when('no') }
  it { should have_valid(:amount).when(0.25) }
  it { should_not have_valid(:amount).when(0.0) }
  it { should have_valid(:exchange_rate).when(0.25) }
  it { should_not have_valid(:exchange_rate).when(0.0) }

  it 'should create with at least two details' do
    a = AccountLedger.new(:date => Date.today)
    a.valid?.should == false
  end

  #it 'should now allow the sum distinct to 0' do
  #  params[:account_ledger_details_attributes][1][:amount] = -50
  #  params[:account_ledger_details_attributes].pop

  #  params[:account_ledger_details_attributes].size.should == 1

  #  a = AccountLedger.new(params)

  #  a.valid?.should == false
  #  a.errors[:base].to_s.should =~ /al menos 2 cuentas/
  #end

  it 'should assing currency_id' do
    a = AccountLedger.new(:account_id => 1)
    a.valid?
    a.currency_id.should == 1
  end

  it 'should return false for money?' do
    al = AccountLedger.new(params)
    al.money?.should == false
  end

  #it 'should update the account value' do
  #  al = AccountLedger.new(params)
  #  al.save.should be_true

  #  al.account.amount.should == 1000
  #  puts "--------"
  #  al.conciliate_account.should be_true
  #  al.reload
  #  al.account.amount.should == 900
  #end

  #it 'should allow negative values' do
  #  params[:operation] = "in"

  #  al = AccountLedger.create(params)

  #  al.persisted?.should == true
  #  al.reload

  #  al.account.amount.should == 1200
  #  al.to.amount.should == -200
  #end

  it 'should not save if the balance with exchange rate is different' do
    params = {
      :date => Date.today, :operation => "in",
      :account_id => 2, :to_id => 1,
      :account_ledger_details_attributes => [
        {:account_id => 2, :amount => 50, :description => "Income with exchange rate 0. from account 1"},
        {:account_id => 1, :amount => -100, :exchange_rate => 0.51,},
      ]
    }

    al = AccountLedger.new(params)
    al.save.should == false
  end

  it 'should create a code' do
    al = AccountLedger.create!(params)
    al.code.should_not be_blank
    al2 = AccountLedger.create!(params)
    al2.code.should == al.code + 1

    OrganisationSession.set id: 2
    al = AccountLedger.create!(params)
    al.code.should == 1
  end

  it 'should not allow repeated code' do
    al = AccountLedger.create!(params)
    al.code.should_not be_blank
    al2 = AccountLedger.new(params) {|a| 
      a.code = al.code
      a.organisation_id = al.organisation_id
    }
    
    al2.valid?.should be_false
    al2.errors[:code].should_not be_blank
  end

  it 'should initialize with money? = false and set validations false' do
    al = AccountLedger.new
    al.money?.should == false
  end

  it 'should initialize with money? = true' do
    AccountLedger.stub!(:new => mock_model(AccountLedger, account_accountable: stub(is_a?: true), :conciliation= => false))
    al = AccountLedger.new_money({:account_id => 1})
    al.should be_money
  end

  it 'should retunr false in case tha account is not MoneyStore' do
    AccountLedger.any_instance.stubs(:account_accountable => Client.new)
    al = AccountLedger.new_money({:account_id => 1})
    al.should be(false)
  end

  it 'should now allow other attributes for new_money' do
    expect {AccountLedger.new_money(:operation => "in", :account_id => 2, :to_id => 5, :amount => 100, :reference => "Yeah", :currency_id => 1, :nuller_id => 1)}.to raise_error ArgumentError

  end

  it 'should return the account_id for MoneyStore' do
    al = AccountLedger.new {|al| 
      al.id = 1
      al.account_id = 1
      al.to_id = 2
    }
    al.stubs(:account_accountable_type => "MoneyStore")

    al.payment_link_id.should == 1
  end

  it 'should return the Contact for Contact' do
    al = AccountLedger.new {|al| 
      al.id = 1
      al.account_id = 1
      al.to_id = 2
    }
    al.stubs(:account_accountable_type => "Contact")

    al.payment_link_id.should == 2
  end

end
