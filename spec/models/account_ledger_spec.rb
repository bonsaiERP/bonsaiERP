require 'spec_helper'

describe AccountLedger do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
    @params = {
      :date => Date.today, :operation => "out",
      :account_ledger_details_attributes => [
        {:account_id => 1, :amount => 100, :reference => "In"},
        {:account_id => 2, :amount => -100, :reference => "Out"},
      ]
    }
    Account.create!(:name => "Juan perez", :account_type_id => 1, :currency_id => 1,
                   :accountable_id => 1, :accountable_type => "Client"
                   ) {|a| a.id = 1; a.amount = 0 }
    Account.create!(:name => "Bank 1", :account_type_id => 1, :currency_id => 1,
                   :accountable_id => 1, :accountable_type => "Bank"
                   ) {|a| a.id = 2; a.amount = 1000}
  end

  it 'should create with at least two details' do
    a = AccountLedger.new(:date => Date.today)
    
    a.valid?.should == false
  end

  it 'should now allow the sum distinct to 0' do
    @params[:account_ledger_details_attributes][1][:amount] = -50
    a = AccountLedger.new(@params)

    a.valid?.should == false
    a.errors[:base].to_s.should_not =~ /al menos 2 cuentas/
    a.errors[:base].to_s.should =~ /error en el balance/
  end

  it 'should be valid if the accounts are balanced' do
    AccountLedger.create!(@params)
  end

  it 'should assing the correct operation to details' do
    al = AccountLedger.create(@params)
    
    al.account_ledger_details.map(&:operation).uniq.should == [ "out" ]
  end

  it 'should not allow uncorrect operations' do
    @params[:operation] = "jojojo"
    al = AccountLedger.new(@params)
    
    al.valid?.should == false
    al.errors[:operation].should_not == blank?
  end

  it 'should update the account value' do
    al = AccountLedger.new(@params)
    al.save.should == true

    al.account_ledger_details.map(&:state).uniq.should == ["con"]

    a1 = Account.find(1)
    a1.amount.should == 100
    a1.amount_currency(a1.currency_id).should == 100

    a2 = Account.find(2)
    a2.amount.should == 900
    a2.amount_currency(1).should == 900

    al = AccountLedger.create(@params)

    a1 = Account.find(1)
    a1.amount.should == 200
    a1.amount_currency( 1 ).should == 200

    a2 = Account.find(2)
    a2.amount.should == 800
    a2.initial_amount.should == 1000
    a2.amount_currency(1).should == 800
  end

  it 'should allow negative values' do
    @params[:operation] = "in"
    @params[:account_ledger_details_attributes][0][:amount] = -200
    @params[:account_ledger_details_attributes][1][:amount] = 200

    al = AccountLedger.create(@params)

    al.persisted?.should == true

    Account.find(1).amount.should == -200
    Account.find(2).amount.should == 1200

    al.account_ledger_details.map(&:operation).uniq.should == ["in"]
  end

  it 'should work with other currencies' do
    @params = {
      :date => Date.today, :operation => "in",
      :account_ledger_details_attributes => [
        {:account_id => 2, :amount => 50, :reference => "In", :description => "Income with exchange rate 0. from account 1"},
        {:account_id => 1, :amount => -100, :reference => "Out", :exchange_rate => 0.5,},
      ]
    }
    al = AccountLedger.new(@params)

    al.save.should == true
    al.account_ledger_details[0].description.should == "Income with exchange rate 0. from account 1"

  end

  it 'should not save if the balance with exchange rate is different' do
    @params = {
      :date => Date.today, :operation => "in",
      :account_ledger_details_attributes => [
        {:account_id => 2, :amount => 50, :reference => "In", :description => "Income with exchange rate 0. from account 1"},
        {:account_id => 1, :amount => -100, :reference => "Out", :exchange_rate => 0.51,},
      ]
    }

    al = AccountLedger.new(@params)
    al.save.should == false
  end

  it 'should store amount for different currencies' do
    Account.create!(:name => "Bank 2", :account_type_id => 1, :currency_id => 2,
                   :accountable_id => 1, :accountable_type => "Bank"
                   ) {|a| a.id = 3; a.amount = 1000}

    AccountLedger.create!(
      :date => Date.today, :operation => "out",
      :account_ledger_details_attributes => [
        {:account_id => 1, :amount => 50, :reference => "In", :currency_id => 2},
        {:account_id => 3, :amount => -100, :reference => "Out", :exchange_rate => 0.5},
      ]
    )
    
    a1 = Account.find(1)
    a1.amount.should == 0
    a1.amount_currency( 1 ).should == 0
    a1.amount_currency( 2 ).should == 50.00

    a2 = Account.find(3)
    a2.amount.should == 900
  end

end
