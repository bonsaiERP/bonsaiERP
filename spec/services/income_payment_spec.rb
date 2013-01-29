# encoding: utf-8
require 'spec_helper'

describe IncomePayment do
  before do
    OrganisationSession.organisation = build :organisation, currency: 'BOB'
  end

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
      #p.income.should be_is_approved
      #p.income.approver_id.should eq(UserSession.id)

      # Ledger
      p.ledger.amount.should == 50.0
      p.ledger.exchange_rate == 1
      p.ledger.should be_is_payin
      p.ledger.account_id.should eq(income.id)
      # Only bank accounts are allowed to conciliate
      p.ledger.should be_conciliation 
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
      p.ledger.should be_conciliation
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

    ### Verification only Bank accounts
    context "Verification only for bank accounts" do
      it "verificates because it is a bank" do
        bank = build :bank, id: 100
        Account.stub(:find_by_id).with(bank.id).and_return(bank)
        bank.id.should_not eq(account_to_id)

        p = IncomePayment.new(valid_attributes.merge(account_to_id: 100, verification: true, interest: 10))

        p.pay.should be_true
        p.should be_verification
        p.account_to_id.should eq(100)
        # Should not conciliate
        p.ledger.should_not be_conciliation
        p.int_ledger.should_not be_conciliation

        # When inverse
        p = IncomePayment.new(valid_attributes.merge(account_to_id: 100, verification: false, interest: 10))

        p.pay.should be_true
        # Should conciliate
        p.ledger.should be_conciliation
        p.int_ledger.should be_conciliation
      end

      it "does not change when its't bank account" do
        cash = build :cash, id: 200
        Account.stub(:find_by_id).with(cash.id).and_return(cash)
        cash.id.should_not eq(account_to_id)

        Account.find_by_id(account_to_id).should eq(account_to)

        p = IncomePayment.new(valid_attributes.merge(account_to_id: 200, verification: true, interest: 10))

        p.pay.should be_true

        p.ledger.should be_conciliation
        p.int_ledger.should be_conciliation

        #inverse
        p = IncomePayment.new(valid_attributes.merge(account_to_id: 200, verification: false, interest: 10))

        p.pay.should be_true

        p.ledger.should be_conciliation
        p.int_ledger.should be_conciliation
      end
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

  context "Pay with expense" do
    let(:expense) { Expense.new_expense(total: 200, balance: 100, state: 'approved') {|e| e.id = 14} }

    let(:expense_payment_attributes) {
      {
        account_id: income.id, account_to_id: expense.id, amount: 50,
        exchange_rate: 1, interest: 10, verification: 'true', 
        date: Date.today, reference: 'Pay with expense'
      }
    }

    before do
      Account.stub(:find_by_id).with(income.id).and_return(income)
      Account.stub(:find_by_id).with(expense.id).and_return(expense)
      AccountLedger.any_instance.stub(save_ledger: true)
    end

    it "is not valid when amount is greater than expense balance" do
      expense.balance = 20
      ip = IncomePayment.new(expense_payment_attributes)

      ip.should_not be_valid

      ip.errors_on(:amount).should eq([I18n.t('errors.messages.payment.expense_balance')])

      expense.balance = 100

      ip.should be_valid
    end

    it "updates the related Expense account" do
      income.stub(save: true)
      expense.stub(save: true)
      expense.balance = 100
      expense.currency = 'BOB'

      bal = income.balance

      ip = IncomePayment.new(expense_payment_attributes)

      bal = income.balance
      # Pay
      ip.pay.should be_true
      # Income
      ip.income.balance.should == bal - ip.amount
      # Expense
      ip.account_to.balance.should == 100 - (ip.amount + ip.interest)
    end

    it "should set the state of the expense when done" do
      expense.state = 'draft'

      ip = IncomePayment.new(expense_payment_attributes)

      ip.should_not be_valid

      ip.errors_on(:account_to_id).should eq([I18n.t('errors.messages.payment.invalid_expense_state')])
    end

    it "sets the state for the expense" do
      income.stub(save: true)
      expense.stub(save: true)
      income.balance = income.total = 100
      expense.balance = expense.total = 100

      income.should be_is_draft
      income.balance.should eq(100)

      expense.should be_is_approved

      ip = IncomePayment.new(expense_payment_attributes.merge(amount: 90, interest: 10))

      ip.pay.should be_true
      # Income
      ip.income.balance.should == 10
      # Expense
      ip.account_to.balance.should == 0
      ip.account_to.should be_is_paid
    end

    # Exchange rate
    it "sets balance based on the currency of expense" do
      income.stub(save: true)
      expense.stub(save: true)
      income.balance = income.total = 100
      expense.balance = expense.total = 100
      expense.currency = 'USD'

      income.should be_is_draft
      income.balance.should eq(100)

      expense.should be_is_approved

      ip = IncomePayment.new(expense_payment_attributes.merge(amount: 10, interest: 1, exchange_rate: 7.0))

      ip.pay.should be_true
      # Income
      ip.income.balance.should == 100 - 7.0 * 10
      # Expense
      ip.account_to.balance.should == 100 - 11

      ########################################
      # Inverse
      income.balance = income.total = 100
      expense.balance = expense.total = 100
      income.currency = 'USD'
      expense.currency = 'BOB'

      ip = IncomePayment.new(expense_payment_attributes.merge(amount: 10, interest: 1, exchange_rate: 7.0))

      ip.pay.should be_true
      # Income
      ip.income.balance.round(4).should == (100 - 1.0/7 * 10).round(4)
      # Expense
      ip.account_to.balance.should == 100 - 11
    end
  end

  context "Pay with different currencies" do
    before do
      income.stub(save: true)
      Income.stub(:find_by_id).with(income.id).and_return(income)
      AccountLedger.any_instance.stub(save_ledger:  true)
    end

    it "uses the exchange_rate for other curerncy" do
      ac_usd = build(:cash, currency: 'USD', id: 101)
      Account.stub_chain(:active, :find_by_id).with(101).and_return(ac_usd)
      income.balance = 100

      ip = IncomePayment.new(valid_attributes.merge(account_to_id: 101, exchange_rate: 7.001, amount: 10, interest: 1))

      ip.pay.should be_true

      ip.amount.should == 10
      # income
      ip.income.currency.should eq('BOB')
      ip.income.balance.should == (100 - 7.001 * 10).round(4)
      # ledger
      ip.ledger.should_not be_inverse
      ip.amount.should == 10
      ip.ledger.currency.should eq('USD')
      # int_ledger
      ip.int_ledger.should_not be_inverse
      ip.int_ledger.amount.should == 1
      ip.int_ledger.currency.should eq('USD')
    end

    it "does the inverse when income in USD" do
      income.currency = 'USD'
      ac_usd = build(:cash, currency: 'BOB', id: 103)
      Account.stub_chain(:active, :find_by_id).with(101).and_return(ac_usd)
      income.balance = 100

      ip = IncomePayment.new(valid_attributes.merge(account_to_id: 101, exchange_rate: 7.001, amount: 200, interest: 1))

      ip.pay.should be_true

      ip.amount.should == 200
      # income
      ip.income.currency.should eq('USD')
      ip.income.balance.should == (100 - 1/7.001 * 200).round(4)
      # ledger
      ip.ledger.should be_inverse
      ip.amount.should == 200
      ip.ledger.currency.should eq('BOB')
      # int_ledger
      ip.int_ledger.should be_inverse
      ip.int_ledger.amount.should == 1
      ip.int_ledger.currency.should eq('BOB')
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
