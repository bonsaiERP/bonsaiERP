# encoding: utf-8
require 'spec_helper'

describe NullAccountLedger do

  before(:each) do
    UserSession.user = build :user, id: 11
    OrganisationSession.organisation = build :organisation, currency: 'BOB'
  end


  it "only allow account ledgers" do
    expect { NullAccountLedger.new(Object.new) }.to raise_error

    NullAccountLedger.new(build :account_ledger)
  end

  it "only nulls active and not conciliated accounts_ledgers" do
    Account.any_instance.stub(save: true)
    ledger = build :account_ledger, status: 'approved', approver_id: 12
    ledger.stub(save: true)

    # Conciliated
    na = NullAccountLedger.new(ledger)
    na.should_not be_valid
    
    # Nulled nulled
    ledger.approver_id = nil
    ledger.nuller_id = 14
    na = NullAccountLedger.new(ledger)
    na.should_not be_valid
  end

  before(:each) do
    UserSession.user = build :user, id: 1
    Account.any_instance.stub(save: true)
    AccountLedger.any_instance.stub(save: true)
  end

  let(:bank_bob) { build :bank, amount: 1000, currency: 'BOB' }
  let(:bank_usd) { build :bank, amount: 1000, currency: 'USD' }

  context "between cash and bank accounts" do
    let(:cash_bob) { build :cash, amount: 1000, currency: 'BOB' }
    let(:cash_usd) { build :cash, amount: 1000, currency: 'USD' }

    it "updates the cash" do
      al = AccountLedger.new(amount: 100.0, currency: 'BOB', status: 'pendent')
      al.account = cash_bob
      al.account_to = bank_bob
      al.should be_is_pendent

      na = NullAccountLedger.new(al)

      na.null.should be_true

      cash_bob.amount.should == 1000.0
      al.should be_is_nulled
    end

    it "updates the cash USD" do
      al = AccountLedger.new(amount: 70.0, currency: 'BOB', status: 'pendent', exchange_rate: 7.0)
      al.account = cash_usd
      al.account_to = bank_bob

      na = NullAccountLedger.new(al)

      na.null.should be_true

      cash_usd.amount.should == 1000.0
      al.should be_is_nulled
    end

    it "updates the banks USD" do
      al = AccountLedger.new(amount: 70.0, currency: 'BOB', status: 'pendent', exchange_rate: 7.0)
      al.account = bank_usd
      al.account_to = bank_bob

      na = NullAccountLedger.new(al)

      na.null.should be_true

      bank_usd.amount.should == 1000.0
      al.should be_is_nulled
    end
  end

  describe 'Null Income/Expense' do

    let(:income) { build :income, balance: 0, state: 'paid', currency: 'BOB' }
    before(:each) { income.stub(save: true) }

    it "nulls a income same currency" do

      income.should be_is_paid

      al = AccountLedger.new(amount: 10.0, currency: 'BOB', status: 'pendent')
      al.account = income
      al.account_to = bank_bob


      na = NullAccountLedger.new(al)

      na.null.should be_true

      na.account.should eq(income)
      income.balance.should == 10.0
      income.should be_is_approved

      al.should be_is_nulled
    end

    it "currency of income is USD" do
      income.currency = 'USD'

      al = AccountLedger.new(amount: 70.0, currency: 'BOB', status: 'pendent', exchange_rate: 7.0)
      al.account = income
      al.account_to = bank_bob

      income.balance.should == 0

      na = NullAccountLedger.new(al)

      Movements::Errors.any_instance.should_receive(:set_errors)
      na.null.should be_true

      na.account.should eq(income)
      income.balance.should == 10.0
      income.should be_is_approved
    end

    it "income BOB account_to USD" do
      income.currency = 'BOB'

      al = AccountLedger.new(amount: 10.0, currency: 'USD', status: 'pendent', exchange_rate: 7.0)
      al.account = income
      al.account_to = bank_usd

      income.balance.should == 0

      na = NullAccountLedger.new(al)

      Movements::Errors.any_instance.should_receive(:set_errors)

      na.null.should be_true

      na.account.should eq(income)
      income.balance.should == 70.0
      income.should be_is_approved
    end
  end
end

