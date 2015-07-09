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
    ledger = build :account_ledger, status: 'approved', approver_id: 12, contact_id: 3
    ledger.save(validate: false)
    ledger.should be_persisted

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
    #AccountLedger.any_instance.stub(save: true)
  end

  let(:bank_bob) { build :bank, amount: 1000, currency: 'BOB', id: 1 }
  let(:bank_usd) { build :bank, amount: 1000, currency: 'USD', id: 2 }

  context "expense" do
    it "nulls expense payout" do
      exp = Expense.new(state: 'approved', total: 100, balance: 50, currency: 'BOB', contact_id: 10)
      exp.stub(save: true)
      exp.id = 200

      al = AccountLedger.new(amount: -50, currency: 'BOB', status: 'pendent', operation: 'payout', date: Date.today, reference: 'Pay expense', account_id: 200, contact_id: 10)
      al.account = exp
      al.account_to = bank_bob

      al.save.should eq(true)
      al.should be_is_pendent

      na = NullAccountLedger.new(al)
      na.null!

      al.should be_is_nulled

      exp.balance.should == 100
    end

    it "nulls expense devout" do
      exp = Expense.new(state: 'approved', total: 100, balance: 50, currency: 'BOB', contact_id: 10)
      exp.stub(save: true)
      exp.id = 200

      al = AccountLedger.new(amount: 50, currency: 'BOB', status: 'pendent', operation: 'devout', date: Date.today, reference: 'Devolution expense', account_id: 200, contact_id: 10)
      al.account = exp
      al.account_to = bank_bob

      al.save.should eq(true)
      al.should be_is_pendent

      na = NullAccountLedger.new(al)
      na.null!

      al.should be_is_nulled

      exp.balance.should == 0
    end
  end

  context "income" do
    it "nulls income payin" do
      inc = Income.new(state: 'approved', total: 100, balance: 50, currency: 'BOB', contact_id: 10)
      inc.stub(save: true)
      inc.id = 200

      al = AccountLedger.new(amount: 50, currency: 'BOB', status: 'pendent', operation: 'payin', date: Date.today, reference: 'Pay income', account_id: 200, contact_id: 10)
      al.account = inc
      al.account_to = bank_bob

      al.save.should eq(true)
      al.should be_is_pendent

      na = NullAccountLedger.new(al)
      na.null!

      al.should be_is_nulled

      inc.balance.should == 100
    end

    it "nulls income devout" do
      inc = Income.new(state: 'approved', total: 100, balance: 50, currency: 'BOB', contact_id: 10)
      inc.stub(save: true)
      inc.id = 200

      al = AccountLedger.new(amount: -50, currency: 'BOB', status: 'pendent', operation: 'payin', date: Date.today, reference: 'Pay income', account_id: 200, contact_id: 10)
      al.account = inc
      al.account_to = bank_bob

      al.save.should eq(true)
      al.should be_is_pendent

      na = NullAccountLedger.new(al)
      na.null!

      al.should be_is_nulled

      inc.balance.should == 0
    end
  end

  context "between cash and bank accounts" do
    let(:cash_bob) { build :cash, amount: 1000, currency: 'BOB' }
    let(:cash_usd) { build :cash, amount: 1000, currency: 'USD' }


    it "updates the income BOB" do
      inc = Income.new(state: 'approved', total: 100, balance: 30, currency: 'BOB', contact_id: 10)
      inc.stub(save: true)
      inc.id = 200

      al = AccountLedger.new(amount: 10, currency: 'USD', exchange_rate: 7, status: 'pendent', operation: 'payin', date: Date.today, reference: 'Pay income', account_id: 200, contact_id: 10)

      al.account = inc
      al.account_to = bank_usd

      al.save.should eq(true)
      al.should be_is_pendent

      na = NullAccountLedger.new(al)

      na.null!.should eq(true)

      inc.balance.should == 100
    end

    it "updates the income USD" do
      inc = Income.new(state: 'approved', total: 100, balance: 90, currency: 'USD', contact_id: 10)
      inc.stub(save: true)
      inc.id = 200

      al = AccountLedger.new(amount: 70, currency: 'BOB', exchange_rate: 7, status: 'pendent', operation: 'payin', date: Date.today, reference: 'Pay income', account_id: 200, inverse: true, contact_id: 10)

      al.account = inc
      al.account_to = bank_bob

      al.save.should eq(true)
      al.should be_is_pendent
      al.should be_inverse

      na = NullAccountLedger.new(al)

      na.null!.should eq(true)

      inc.balance.should == 100
    end

    it "updates the income USD devolution" do
      inc = Income.new(state: 'approved', total: 100, balance: 90, currency: 'USD', contact_id: 10)
      inc.stub(save: true)
      inc.id = 200

      al = AccountLedger.new(amount: -70, currency: 'BOB', exchange_rate: 7, status: 'pendent', operation: 'devin', date: Date.today, reference: 'Pay income', account_id: 200, inverse: true, contact_id: 10)

      al.account = inc
      al.account_to = bank_bob

      al.save.should eq(true)
      al.should be_is_pendent
      al.should be_inverse

      na = NullAccountLedger.new(al)

      na.null!.should eq(true)

      inc.balance.should == 80
    end
  end

  describe 'Loans' do
    # Loans::Give
    it "payment+" do
      ledger = AccountLedger.new(amount: 200, operation: 'lgpay')
      loan = Loans::Give.new(total: 1000, amount: 800)
      loan.stub(save: true)
      ledger.stub(account: loan, save: true)

      nl = NullAccountLedger.new(ledger)
      nl.null!.should eq(true)
      loan.total.should == 1000
      loan.amount.should == 1000
    end

    it "interest+" do
      ledger = AccountLedger.new(amount: 200, operation: 'lgint')
      loan = Loans::Give.new(total: 1000, amount: 800)
      loan.stub(save: true)
      ledger.stub(account: loan, save: true)

      nl = NullAccountLedger.new(ledger)
      nl.null!.should eq(true)
      loan.total.should == 1000
      loan.amount.should == 1000
    end

    # Loans::Receive
    it "payment-" do
      ledger = AccountLedger.new(amount: -200, operation: 'lrpay')
      loan = Loans::Receive.new(total: 1000, amount: 800)
      loan.stub(save: true)

      ledger.stub(account: loan, save: true)
      nl = NullAccountLedger.new(ledger)
      nl.null!.should eq(true)
      loan.total.should == 1000
      loan.amount.should == 1000
    end

    it "interest-" do
      ledger = AccountLedger.new(amount: -200, operation: 'lrpay')
      loan = Loans::Receive.new(total: 1000, amount: 800)
      loan.stub(save: true)

      ledger.stub(account: loan, save: true)
      nl = NullAccountLedger.new(ledger)
      nl.null!.should eq(true)
      loan.total.should == 1000
      loan.amount.should == 1000
    end
  end

end
