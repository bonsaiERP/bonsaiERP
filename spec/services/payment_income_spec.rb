# encoding: utf-8
require 'spec_helper'

describe PaymentIncome do
  let(:valid_attributes) {
    {
      transaction_id: 10, account_id: 2, exchange_rate: 1,
      amount: 50, interest: 0, reference: 'El primer pago',
      verification: 'true'
    }
  }
  let(:balance) { 100.0 }

  let(:transaction_id) { valid_attributes[:transaction_id] }
  let(:account_id) { valid_attributes[:account_id] }

  let(:account_id) { valid_attributes[:account_id] }
  let(:currency) { build :currency, id: 10 }
  let(:contact) { build :contact, id: 11 }
  let(:income) { build :income, id: transaction_id, balance: balance, currency: currency, contact: contact }
  let(:account) { build :account, id: account_id, amount: 100 }

  it "income" do
    income.should be_valid
  end

  context "create payment" do
    before(:each) do
      income.stub(save: true)
      #Income.should_receive(:find).at_least(:once).with(transaction_id).and_return(income)
      Income.stub(:find).with(transaction_id).and_return(income)
      Account.stub(:find).with(account_id).and_return(account)
      AccountLedger.any_instance.stub(save: true)
    end

    it "Payments" do
      income.should be_is_draft
      p = PaymentIncome.new(valid_attributes)

      p.pay.should  be_true

      # Income
      p.income.should be_is_a(Income)
      p.income.balance.should == balance - valid_attributes[:amount]
      p.income.should be_is_approved

      # Ledger
      p.ledger.amount.should == 50.0
      p.ledger.should be_is_payin
      p.ledger.transaction_id.should eq(income.id)
      p.ledger.should be_conciliation

      p.int_ledger.should be_nil

      # New payment to complete
      Income.stub(:find).with(transaction_id).and_return(p.income)
      p = PaymentIncome.new(valid_attributes.merge(amount: p.income.balance))
      p.pay.should be_true

      p.income.balance.should == 0
      p.income.should be_is_paid
    end

    it "create ledger and int_ledger" do
      income.should be_is_draft
      p = PaymentIncome.new(valid_attributes.merge(interest: 10))

      p.pay.should be_true

      # ledger
      p.ledger.should be_is_a(AccountLedger)
      p.ledger.amount.should == valid_attributes[:amount]
      # int_ledger
      p.int_ledger.should be_is_a(AccountLedger)
      p.int_ledger.amount.should == 10.0
    end

    it "only creates int_ledger" do
      income.should be_is_draft
      p = PaymentIncome.new(valid_attributes.merge(interest: 10, amount: 0))

      p.pay.should be_true

      # ledger
      p.ledger.should be_nil
      # int_ledger
      p.int_ledger.should be_is_a(AccountLedger)
      p.int_ledger.amount.should == 10.0
    end
  end

  context "Errors" do
    before(:each) do
      income.stub(save: false)
      Income.stub(:find).with(transaction_id).and_return(income)
      Account.stub(:find).with(account_id).and_return(account)
      AccountLedger.any_instance.stub(save: true)
    end

    it "does not save" do
      p = PaymentIncome.new(valid_attributes)

      p.pay.should be_false
    end
  end
end
