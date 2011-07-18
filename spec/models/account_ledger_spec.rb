# encoding: utf-8
require 'spec_helper'

describe AccountLedger do
  let(:params) do
    {
      :date => Date.today, :operation => "out", :reference => "Income", :amount => 100, :currency_id => 1, :exchange_rate => 1,
      :account_id => 2, :to_id => 1,
      :account_ledger_details_attributes => [
        {:account_id => 1, :amount => 100 },
        {:account_id => 2, :amount => -100 },
      ]
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

  it 'should now allow the sum distinct to 0' do
    params[:account_ledger_details_attributes][1][:amount] = -50
    params[:account_ledger_details_attributes].pop

    params[:account_ledger_details_attributes].size.should == 1

    a = AccountLedger.new(params)

    a.valid?.should == false
    a.errors[:base].to_s.should =~ /al menos 2 cuentas/
  end

  it 'should assing currency_id' do
    a = AccountLedger.new(:currency_id => 1)
    a.valid?
    a.currency_id.should == 1
  end

  it 'should be valid if the accounts are balanced' do
    a = AccountLedger.create(params)
    a.account_ledger_details.inject(0) {|sum,v| sum += v.amount }.should == 0
  end

  it 'should not allow uncorrect operations' do
    params[:operation] = "jojojo"
    al = AccountLedger.new(params)
    
    al.valid?.should == false
    al.errors[:operation].should_not == blank?
  end

  it 'should return false for money?' do
    al = AccountLedger.new(params)
    al.money?.should == false
  end

  it 'should update the account value' do
    al = AccountLedger.new(params)
    al.save.should == true

    al.account_ledger_details.map(&:state).uniq.should == ["con"]

    a1 = Account.find(1)
    a1.amount.should == 100
    a1.amount_currency(a1.currency_id).should == 100

    a2 = Account.find(2)
    a2.amount.should == 900
    a2.amount_currency(1).should == 900

    al = AccountLedger.create(params)

    a1 = Account.find(1)
    a1.amount.should == 200
    a1.amount_currency( 1 ).should == 200

    a2 = Account.find(2)
    a2.amount.should == 800
    a2.initial_amount.should == 1000
    a2.amount_currency(1).should == 800
  end

  it 'should allow negative values' do
    params[:operation] = "in"
    params[:account_ledger_details_attributes][0][:amount] = -200
    params[:account_ledger_details_attributes][1][:amount] = 200

    al = AccountLedger.create(params)

    al.persisted?.should == true
    al.reload

    al.account_ledger_details.find_by_account_id(1).amount.should == -200
    al.account_ledger_details.find_by_account_id(2).amount.should == 200

    Account.find(1).amount.should == -200
    Account.find(2).amount.should == 1200
  end

  it 'should work with other currencies' do
    params = {
      :date => Date.today, :operation => "in", :reference => "Income", :amount => 50, :currency_id => 1, :exchange_rate => 0.5,
      :account_id => 2, :to_id => 1,
      :account_ledger_details_attributes => [
        {:account_id => 2, :amount => 50, :description => "Income with exchange rate 0. from account 1"},
        {:account_id => 1, :amount => -100, :exchange_rate => 0.5,},
      ]
    }

    al = AccountLedger.new(params)
    al.save.should == true
    al.account_ledger_details[0].description.should == "Income with exchange rate 0. from account 1"

  end

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

  it 'should store amount for different currencies' do
    Currency.create!(:name => 'Dolar', :symbol => '$us' )

    Account.create!(:name => "Bank 2", :account_type_id => 1, :currency_id => 2,
                   :accountable_id => 1, :accountable_type => "Bank"
                   ) {|a| a.id = 3; a.amount = 1000}

    al = AccountLedger.create!(
      :date => Date.today, :operation => "out", :reference => "Outcome", :amount => 50, :currency_id => 2, :exchange_rate => 0.5,
      :account_id => 3, :to_id => 1,
      :account_ledger_details_attributes => [
        {:account_id => 1, :amount => 50, :currency_id => 2},
        {:account_id => 3, :amount => -100, :exchange_rate => 0.5},
      ]
    )
    
    a1 = al.account_ledger_details[0].account
    a1.amount.should == 50
    a1.amount_currency( 1 ).should == 0
    a1.amount_currency( 2 ).should == 50.00

    a2 = Account.find(3)
    a2.amount.should == 900
  end

  it 'should initialize with money? = false and set validations false' do
    al = AccountLedger.new
    al.money?.should == false

    al.valid?.should == false
    al.errors[:account_id].any?.should == true
    al.errors[:to_id].any?.should == true
  end

  it 'should initialize with money? = true' do
    al = AccountLedger.new_money({})
    al.money?.should == true

    al.valid?.should == false
    al.errors[:account_id].any?.should == true
    al.errors[:to_id].any?.should == true
  end

  it 'should now allow other attributes for new_money' do
    expect {AccountLedger.new_money(:operation => "in", :account_id => 2, :to_id => 5, :amount => 100, :reference => "Yeah", :currency_id => 1)}.to raise_error ArgumentError

  end
end
