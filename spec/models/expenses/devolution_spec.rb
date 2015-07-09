# encoding: utf-8
require 'spec_helper'

describe Expenses::Devolution do

  let(:valid_attributes) {
    {
      account_id: 10, account_to_id: 2, exchange_rate: 1,
      amount: 50, reference: 'Primera devolucion',
      verification: 'true', date: Date.today
    }
  }
  let(:balance) { 100.0 }
  let(:total) { balance + 100 }

  let(:account_id) { valid_attributes.fetch(:account_id) }
  let(:account_to_id) { valid_attributes.fetch(:account_to_id) }

  let(:contact) { build :contact, id: 11 }
  let(:expense) do
    Expense.new(
      total: total, balance: balance, currency: 'BOB', contact_id: contact.id
    ) {|e|
      e.id = account_id
      e.contact = contact
    }
  end
  let(:account_to) { build :account, id: account_to_id, amount: 100 }

  before(:each) do
    UserSession.user = build :user, id: 10
  end

  it "#expense" do
    exp_dev = Expenses::Devolution.new(account_id: 1)
    Expense.should_receive(:where).with(id: 1).and_return([Expense])
    Expense.should_receive(:active).and_return(Expense)
    exp_dev.expense.should eq(Expense)
  end

  context 'Validations' do
    it "validates presence of expense" do
      exp_dev = Expenses::Devolution.new(valid_attributes.merge(expense_id: nil))
      expect(exp_dev.valid?).to eq(false)
      expect(exp_dev.errors[:expense].present?).to eq(true)

      Expense.stub_chain(:active, where: [expense])
      expect(exp_dev.valid?).to eq(false)

      expect(exp_dev.errors[:expense].blank?).to eq(true)
    end

    it "does not allow amount greater than total" do
      exp_dev = Expenses::Devolution.new(valid_attributes.merge(amount: 101))

      Expense.stub_chain(:active, where: [expense])
      Account.stub(where: [account_to])

      exp_dev.should_not be_valid
      expect(exp_dev.errors[:amount].present?).to eq(true)

      exp_dev.amount = 100
      expect(exp_dev.valid?).to eq(true)
    end
  end

  context "create devolution" do
    before(:each) do
      expense.stub(save: true)
      Expense.stub_chain(:active, :where).with(id: account_id).and_return([expense])
      Account.stub(:where).with(id: account_to_id).and_return([account_to])
      AccountLedger.any_instance.stub(save_ledger: true)
    end

    it "Devolution" do
      expense.state = 'paid'
      expense.approver_id = 1
      expense.has_error = true

      dev = Expenses::Devolution.new(valid_attributes)
      ### Payment
      dev.pay_back.should  eq(true)

      dev.should be_verification

      # Expense
      dev.expense.should be_is_a(Expense)
      dev.expense.balance.should == balance + valid_attributes[:amount]
      dev.expense.operation_type.should eq('ledger_in')
      dev.expense.should_not be_has_error

      # Ledger
      dev.ledger.amount.should == 50.0
      dev.ledger.exchange_rate == 1
      dev.ledger.should be_is_devout
      dev.ledger.account_id.should eq(expense.id)

      dev.ledger.contact_id.should_not be_blank
      dev.ledger.contact_id.should eq(expense.contact_id)
      # Only bank accounts are allowed to conciliate
      dev.ledger.should be_is_approved
      dev.ledger.reference.should eq(valid_attributes.fetch(:reference))
      dev.ledger.date.should eq(valid_attributes.fetch(:date).to_date)
    end

    ### Verification only bank accounts
    context "Verification only for bank accounts" do
      it "verificates because it is a bank" do
        bank = build :bank, id: 100
        Account.stub(:where).with(id: bank.id).and_return([bank])
        bank.id.should_not eq(account_to_id)

        dev = Expenses::Devolution.new(valid_attributes.merge(account_to_id: 100, verification: true))

        dev.pay_back.should eq(true)
        dev.should be_verification
        dev.account_to.should eq(bank)
        # Should not conciliate
        dev.ledger.should be_is_pendent

        # When inverse
        dev = Expenses::Devolution.new(valid_attributes.merge(account_to_id: 100, verification: false, interest: 10))

        dev.pay_back.should eq(true)
        dev.account_to.should eq(bank)
        # Should conciliate
        dev.ledger.should be_is_approved
      end

      it "does not change when its't bank account" do
        cash = build :cash, id: 200
        Account.stub(:where).with(id: cash.id).and_return([cash])
        cash.id.should_not eq(account_to_id)

        dev = Expenses::Devolution.new(valid_attributes.merge(account_to_id: 200, verification: true))

        dev.pay_back.should eq(true)

        dev.ledger.should be_is_approved

        #inverse
        dev = Expenses::Devolution.new(valid_attributes.merge(account_to_id: 200, verification: false))

        dev.pay_back.should eq(true)

        dev.ledger.should be_is_approved
      end
    end
  end

  context "Errors" do
    it "does not save if invalid Expenses::Devolution" do
      Expense.any_instance.should_not_receive(:save)
      p = Expenses::Devolution.new(valid_attributes.merge(reference: ''))
      p.pay_back.should eq(false)
    end

    before(:each) do
      expense.stub(save: false, errors: {balance: 'No balance'})
      Expense.stub_chain(:active, where: [expense])
      Account.stub(:find_by_id).with(account_to_id).and_return(account_to)
      AccountLedger.any_instance.stub(save_ledger: false, errors: {amount: 'Not real'})
    end

    #it "sets errors from other clases" do
    #  dev = Expenses::Devolution.new(valid_attributes)
    #  dev.stub(account_to: true)

    #  dev.pay_back.should eq(false)
    #  # There is no method Expenses::Devolution#balance
    #  dev.errors[:amount].should eq(['Not real'])
    #  # There is a method Expenses::Devolution#amount
    #  dev.errors[:base].should eq(['No balance'])
    #end
  end
end
