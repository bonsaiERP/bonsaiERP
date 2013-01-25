# encoding: utf-8
require 'spec_helper'

describe IncomeDevolution do
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
  let(:income) do
    Income.new_income(
      total: balance, balance: balance, currency: 'BOB', contact_id: contact.id
    ) {|i| 
      i.id = account_id
      i.contact = contact
    }
  end
  let(:account_to) { build :account, id: account_to_id, amount: 100 }

  before(:each) do
    UserSession.user = build :user, id: 10
  end

  context 'Validations' do
    it "validates presence of income" do
      pay_in = IncomePayment.new(valid_attributes)
      pay_in.should_not be_valid
      pay_in.errors_on(:income).should_not be_empty

      Income.stub(find_by_id: income)
      Account.stub(find_by_id: account_to)
      pay_in.should be_valid
    end

    it "does not allow amount greater than balance" do
      pay_in = IncomePayment.new(valid_attributes.merge(amount: 101))

      Income.stub(find_by_id: income)
      Account.stub(find_by_id: account_to)

      pay_in.should_not be_valid
      pay_in.errors_on(:amount).should_not be_empty

      pay_in.amount = 100
      pay_in.should be_valid
    end
  end

  context "create payment" do
    before(:each) do
      income.stub(save: true)
      Income.stub(:find_by_id).with(account_id).and_return(income)
      Account.stub(:find_by_id).with(account_to_id).and_return(account_to)
      AccountLedger.any_instance.stub(save_ledger: true)
    end

    it "Payments" do
      income.should be_is_draft
      income.approver_id.should be_nil

      p = IncomePayment.new(valid_attributes)

      p.pay.should  be_true
      p.verification.should be_true

      # Income
      p.income.should be_is_a(Income)
      p.income.balance.should == balance - valid_attributes[:amount]
      p.income.should be_is_approved
      p.income.approver_id.should eq(UserSession.id)

      # Ledger
      p.ledger.amount.should == 50.0
      p.ledger.exchange_rate == 1
      p.ledger.should be_is_payin
      p.ledger.account_id.should eq(income.id)
      p.ledger.should_not be_conciliation
      p.ledger.reference.should eq(valid_attributes.fetch(:reference))
      p.ledger.date.should eq(valid_attributes.fetch(:date).to_time)

      p.int_ledger.should be_nil

      # New payment to complete
      p = IncomePayment.new(valid_attributes.merge(amount: p.income.balance))
      p.pay.should be_true

      p.income.balance.should == 0
      p.income.should be_is_paid
    end

    it "create ledger and int_ledger" do
      income.should be_is_draft
      p = IncomePayment.new(valid_attributes.merge(interest: 10))

      p.verification.should be_true

      p.pay.should be_true

      # ledger
      p.ledger.should_not be_conciliation
      p.ledger.should be_is_a(AccountLedger)
      p.ledger.amount.should == valid_attributes[:amount]
      p.ledger.should be_is_payin
      p.ledger.account_id.should eq(income.id)

      # int_ledger
      p.int_ledger.should be_is_a(AccountLedger)
      p.int_ledger.amount.should == 10.0
      p.int_ledger.should be_is_intin
      p.int_ledger.account_id.should eq(income.id)
      p.int_ledger.reference.should eq(valid_attributes.fetch(:reference))
      p.int_ledger.date.should eq(valid_attributes.fetch(:date).to_time)
    end

    it "creates ledger  and conciliates ledger" do
      income.should be_is_draft
      p = IncomePayment.new(valid_attributes.merge(verification: false))

      p.pay.should be_true
      # ledger
      p.ledger.should be_is_a(AccountLedger)
      p.ledger.should be_conciliation
    end

    it "only creates int_ledger" do
      income.should be_is_draft
      p = IncomePayment.new(valid_attributes.merge(interest: 10, amount: 0))

      p.pay.should be_true

      # ledger
      p.ledger.should be_nil
      # int_ledger
      p.int_ledger.should be_is_a(AccountLedger)
      p.int_ledger.amount.should == 10.0
      p.int_ledger.should be_is_intin
    end
  end

  context "Errors" do
    it "does not save if invalid IncomePayment" do
      Income.any_instance.should_not_receive(:save)
      p = IncomePayment.new(valid_attributes.merge(reference: ''))
      p.pay.should be_false
    end

    before(:each) do
      income.stub(save: false, errors: {balance: 'No balance'})
      Income.stub(:find_by_id).with(account_id).and_return(income)
      Account.stub(:find_by_id).with(account_to_id).and_return(account_to)
      AccountLedger.any_instance.stub(save_ledger: false, errors: {amount: 'Not real'})
    end

    it "sets errors from other clases" do
      p = IncomePayment.new(valid_attributes)

      p.pay.should be_false
      # There is no method IncomePayment#balance
      p.errors[:amount].should eq(['Not real'])
      # There is a method IncomePayment#amount
      p.errors[:base].should eq(['No balance'])
    end
  end
end
