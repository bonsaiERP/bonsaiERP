# encoding: utf-8
require 'spec_helper'

describe IncomeDevolution do

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
  let(:income) do
    Income.new_income(
      total: total, balance: balance, currency: 'BOB', contact_id: contact.id
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
      in_dev = IncomeDevolution.new(valid_attributes)
      in_dev.should_not be_valid
      in_dev.errors_on(:income).should_not be_empty

      Income.stub(find_by_id: income)
      in_dev.should_not be_valid
      
      in_dev.errors_on(:income).should be_blank
    end

    it "does not allow amount greater than total" do
      in_dev = IncomeDevolution.new(valid_attributes.merge(amount: 101))

      Income.stub(find_by_id: income)
      Account.stub(find_by_id: account_to)

      in_dev.should_not be_valid
      in_dev.errors_on(:amount).should_not be_empty

      in_dev.amount = 100
      in_dev.should be_valid
    end
  end

  context "create devolution" do
    before(:each) do
      income.stub(save: true)
      Income.stub(:find_by_id).with(account_id).and_return(income)
      Account.stub(:find_by_id).with(account_to_id).and_return(account_to)
      AccountLedger.any_instance.stub(save_ledger: true)
    end

    it "Devolution" do
      income.state = 'paid'
      income.approver_id = 1
      income.has_error = true

      dev = IncomeDevolution.new(valid_attributes)
      ### Payment
      dev.pay_back.should  be_true

      dev.should be_verification

      # Income
      dev.income.should be_is_a(Income)
      dev.income.balance.should == balance + valid_attributes[:amount]
      dev.income.should_not be_has_error

      # Ledger
      dev.ledger.amount.should == -50.0
      dev.ledger.exchange_rate == 1
      dev.ledger.should be_is_devin
      dev.ledger.account_id.should eq(income.id)
      # Only bank accounts are allowed to conciliate
      dev.ledger.should be_is_approved 
      dev.ledger.reference.should eq(valid_attributes.fetch(:reference))
      dev.ledger.date.should eq(valid_attributes.fetch(:date).to_time)
    end

    ### Verification only bank accounts
    context "Verification only for bank accounts" do
      it "verificates because it is a bank" do
        bank = build :bank, id: 100
        Account.stub(:find_by_id).with(bank.id).and_return(bank)
        bank.id.should_not eq(account_to_id)

        dev = IncomeDevolution.new(valid_attributes.merge(account_to_id: 100, verification: true))

        dev.pay_back.should be_true
        dev.should be_verification
        dev.account_to.should eq(bank)
        # Should not conciliate
        dev.ledger.should be_is_pendent

        # When inverse
        dev = IncomeDevolution.new(valid_attributes.merge(account_to_id: 100, verification: false, interest: 10))

        dev.pay_back.should be_true
        dev.account_to.should eq(bank)
        # Should conciliate
        dev.ledger.should be_is_approved
      end

      it "does not change when its't bank account" do
        cash = build :cash, id: 200
        Account.stub(:find_by_id).with(cash.id).and_return(cash)
        cash.id.should_not eq(account_to_id)

        Account.find_by_id(account_to_id).should eq(account_to)

        dev = IncomeDevolution.new(valid_attributes.merge(account_to_id: 200, verification: true))

        dev.pay_back.should be_true

        dev.ledger.should be_is_approved

        #inverse
        dev = IncomeDevolution.new(valid_attributes.merge(account_to_id: 200, verification: false))

        dev.pay_back.should be_true

        dev.ledger.should be_is_approved
      end
    end
  end

  context "Errors" do
    it "does not save if invalid IncomeDevolution" do
      Income.any_instance.should_not_receive(:save)
      p = IncomeDevolution.new(valid_attributes.merge(reference: ''))
      p.pay_back.should be_false
    end

    before(:each) do
      income.stub(save: false, errors: {balance: 'No balance'})
      Income.stub(:find_by_id).with(account_id).and_return(income)
      Account.stub(:find_by_id).with(account_to_id).and_return(account_to)
      AccountLedger.any_instance.stub(save_ledger: false, errors: {amount: 'Not real'})
    end

    it "sets errors from other clases" do
      dev = IncomeDevolution.new(valid_attributes)

      dev.pay_back.should be_false
      # There is no method IncomeDevolution#balance
      dev.errors[:amount].should eq(['Not real'])
      # There is a method IncomeDevolution#amount
      dev.errors[:base].should eq(['No balance'])
    end
  end
end
