# encoding: utf-8
require 'spec_helper'

describe ExpensePayment do
  let(:valid_attributes) {
    {
      account_id: 10, account_to_id: 2, exchange_rate: 1,
      amount: 50, interest: 0, reference: 'El primer pago',
      verification: 'true', date: Date.today
    }
  }
  let(:balance) { 100.0 }

  let(:account_id) { valid_attributes.fetch(:account_id) }
  let(:account_to_id) { valid_attributes.fetch(:account_to_id) }

  let(:contact) { build :contact, id: 11 }
  let(:expense) do
    Expense.new_expense(
      total: balance, balance: balance, currency: 'BOB', contact_id: contact.id
    ) {|i| 
      i.id = account_id
      i.contact = contact
    }
  end
  let(:account_to) { build :account, id: account_to_id, amount: 100 }

  context 'Validations' do
    it "validates presence of expense" do
      pay_out = ExpensePayment.new(valid_attributes)
      pay_out.should_not be_valid
      pay_out.errors_on(:expense).should_not be_empty

      Expense.stub(find_by_id: expense)
      Account.stub(find_by_id: account_to)
      pay_out.should be_valid
    end

    it "does not allow amount greater than balance" do
      pay_out = ExpensePayment.new(valid_attributes.merge(amount: 101))

      Expense.stub(find_by_id: expense)
      Account.stub(find_by_id: account_to)

      pay_out.should_not be_valid
      pay_out.errors_on(:amount).should_not be_empty

      pay_out.amount = 100
      pay_out.should be_valid
    end
  end

  context "create payment" do
    before(:each) do
      expense.stub(save: true)
      Expense.stub(:find_by_id).with(account_id).and_return(expense)
      Account.stub(:find_by_id).with(account_to_id).and_return(account_to)
      AccountLedger.any_instance.stub(save_ledger: true)
    end

    it "makes the payment" do
      expense.should be_is_draft
      p = ExpensePayment.new(valid_attributes)

      p.pay.should  be_true

      # Expense
      p.expense.should be_is_a(Expense)
      p.expense.balance.should == balance - valid_attributes[:amount]
      p.expense.should be_is_approved

      # Ledger
      p.ledger.should_not be_conciliation
      p.ledger.amount.should == 50.0
      p.ledger.exchange_rate == 1
      p.ledger.should be_is_payout
      p.ledger.account_id.should eq(expense.id)
      p.ledger.reference.should eq(valid_attributes.fetch(:reference))
      p.ledger.date.should eq(valid_attributes.fetch(:date).to_time)

      p.int_ledger.should be_nil

      # New payment to complete
      p = ExpensePayment.new(valid_attributes.merge(amount: p.expense.balance))
      p.pay.should be_true

      p.expense.balance.should == 0
      p.expense.should be_is_paid
    end

    it "conciliates with payment" do
      expense.should be_is_draft
      p = ExpensePayment.new(valid_attributes.merge(verification: false))

      p.verification.should be_false
      p.pay.should  be_true

      p.ledger.should be_conciliation
    end

    it "create ledger and int_ledger" do
      expense.should be_is_draft
      p = ExpensePayment.new(valid_attributes.merge(interest: 10))

      p.pay.should be_true

      # ledger
      p.ledger.should be_is_a(AccountLedger)
      p.ledger.amount.should == valid_attributes[:amount]
      p.ledger.should be_is_payout
      p.ledger.account_id.should eq(expense.id)

      # int_ledger
      p.int_ledger.should be_is_a(AccountLedger)
      p.int_ledger.amount.should == 10.0
      p.int_ledger.should be_is_intout
      p.int_ledger.account_id.should eq(expense.id)
      p.int_ledger.reference.should eq(valid_attributes.fetch(:reference))
      p.int_ledger.date.should eq(valid_attributes.fetch(:date).to_time)
    end

    it "only creates int_ledger" do
      expense.should be_is_draft
      p = ExpensePayment.new(valid_attributes.merge(interest: 10, amount: 0))

      p.pay.should be_true

      # ledger
      p.ledger.should be_nil
      # int_ledger
      p.int_ledger.should be_is_a(AccountLedger)
      p.int_ledger.amount.should == 10.0
      p.int_ledger.should be_is_intout
    end
  end

  context "Errors" do
    it "does not save if invalid ExpensePayment" do
      Expense.any_instance.should_not_receive(:save)
      p = ExpensePayment.new(valid_attributes.merge(reference: ''))
      p.pay.should be_false
    end

    before(:each) do
      expense.stub(save: false, errors: {balance: 'No balance'})
      Expense.stub(:find_by_id).with(account_id).and_return(expense)
      Account.stub(:find_by_id).with(account_to_id).and_return(account_to)
      AccountLedger.any_instance.stub(save: false, errors: {amount: 'Not real'})
    end

    it "sets errors from other clases" do
      p = ExpensePayment.new(valid_attributes)

      p.pay.should be_false
      # There is no method ExpensePayment#balance
      p.errors[:amount].should eq(['Not real'])
      # There is a method ExpensePayment#amount
      p.errors[:base].should eq(['No balance'])
    end
  end
end

