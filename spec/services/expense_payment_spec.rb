# encoding: utf-8
require 'spec_helper'

describe ExpensePayment do
  before(:each) do
    OrganisationSession.organisation = build :organisation, currency: 'BOB'
    UserSession.user = build :user, id: 12
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

    it "Payment" do
      expense.should be_is_draft
      expense.approver_id.should be_nil

      p = ExpensePayment.new(valid_attributes)

      p.pay.should  be_true
      p.verification.should be_true

      # Expense
      p.expense.should be_is_a(Expense)
      p.expense.balance.should == balance - valid_attributes[:amount]
      p.expense.should be_is_approved
      p.expense.approver_id.should eq(UserSession.id)

      # Ledger
      p.ledger.amount.should == 50.0
      p.ledger.exchange_rate == 1
      p.ledger.should be_is_payout
      p.ledger.account_id.should eq(expense.id)
      # Only bank accounts are allowed to conciliate
      p.ledger.should be_conciliation 
      p.ledger.reference.should eq(valid_attributes.fetch(:reference))
      p.ledger.date.should eq(valid_attributes.fetch(:date).to_time)

      p.int_ledger.should be_nil

      # New payment to complete
      p = ExpensePayment.new(valid_attributes.merge(amount: p.expense.balance))
      p.pay.should be_true

      p.expense.balance.should == 0
      p.expense.should be_is_paid
    end

    it "create ledger and int_ledger" do
      expense.should be_is_draft
      p = ExpensePayment.new(valid_attributes.merge(interest: 10))

      p.verification.should be_true

      p.pay.should be_true

      # ledger
      p.ledger.should be_is_a(AccountLedger)
      p.ledger.amount.should == valid_attributes.fetch(:amount)
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

    ### Verification only Bank accounts
    context "Verification only for bank accounts" do
      it "verificates because it is a bank" do
        bank = build :bank, id: 100
        Account.stub(:find_by_id).with(bank.id).and_return(bank)
        bank.id.should_not eq(account_to_id)

        p = ExpensePayment.new(valid_attributes.merge(account_to_id: 100, verification: true, interest: 10))

        p.pay.should be_true
        p.should be_verification
        p.account_to_id.should eq(100)
        # Should not conciliate
        p.ledger.should_not be_conciliation
        p.int_ledger.should_not be_conciliation

        # When verification=false
        p = ExpensePayment.new(valid_attributes.merge(account_to_id: 100, verification: false, interest: 10))

        p.pay.should be_true
        # Should conciliate
        p.ledger.should be_conciliation
        p.int_ledger.should be_conciliation
      end

      it "doesn't change unless it's bank account" do
        cash = build :cash, id: 200
        Account.stub(:find_by_id).with(cash.id).and_return(cash)
        cash.id.should_not eq(account_to_id)

        Account.find_by_id(account_to_id).should eq(account_to)

        p = ExpensePayment.new(valid_attributes.merge(account_to_id: 200, verification: true, interest: 10))

        p.pay.should be_true

        p.ledger.should be_conciliation
        p.int_ledger.should be_conciliation

        # verification=false
        p = ExpensePayment.new(valid_attributes.merge(account_to_id: 200, verification: false, interest: 10))

        p.pay.should be_true

        p.ledger.should be_conciliation
        p.int_ledger.should be_conciliation
      end
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

  context "Pay with income" do
    let(:income) { Income.new_income(total: 200, balance: 100, state: 'approved', currency: 'BOB') {|e| e.id = 14} }

    let(:payment_with_income_attributes) {
      {
        account_id: expense.id, account_to_id: income.id, amount: 50,
        exchange_rate: 1, interest: 10, verification: 'true', 
        date: Date.today, reference: 'Pay with expense'
      }
    }

    before(:each) do
      Account.stub(:find_by_id).with(expense.id).and_return(expense)
      Account.stub(:find_by_id).with(income.id).and_return(income)
      AccountLedger.any_instance.stub(save_ledger: true)
    end

    it "is not valid when amount is greater than expense balance" do
      income.balance = 20
      ep = ExpensePayment.new(payment_with_income_attributes)

      ep.should_not be_valid

      ep.errors_on(:amount).should eq([I18n.t('errors.messages.payment.income_balance')])

      income.balance = 100

      ep.should be_valid
    end

    it "updates the related Income account" do
      expense.stub(save: true)
      income.stub(save: true)
      income.balance = 100
      income.currency = 'BOB'

      bal = expense.balance

      ep = ExpensePayment.new(payment_with_income_attributes)

      bal = expense.balance
      # Pay
      ep.pay.should be_true
      # Expense
      ep.expense.balance.should == bal - ep.amount
      # Expense
      ep.account_to.balance.should == 100 - (ep.amount + ep.interest)
    end

    it "should set the state of the expense when done" do
      income.state = 'draft'

      ep = ExpensePayment.new(payment_with_income_attributes)

      ep.should_not be_valid

      ep.errors_on(:account_to_id).should eq([I18n.t('errors.messages.payment.invalid_income_state')])
    end

    it "sets the state for the income" do
      expense.stub(save: true)
      income.stub(save: true)
      expense.balance = expense.total = 100
      income.balance = income.total = 100

      expense.should be_is_draft
      expense.balance.should eq(100)

      income.should be_is_approved

      ep = ExpensePayment.new(payment_with_income_attributes.merge(amount: 90, interest: 10))

      ep.pay.should be_true
      # Expense
      ep.expense.balance.should == 10
      # Income
      ep.account_to.balance.should == 0
      ep.account_to.should be_is_paid
    end

    # Exchange rate
    it "sets balance based on the currency of income" do
      expense.stub(save: true)
      income.stub(save: true)
      expense.balance = expense.total = 100
      income.balance = income.total = 100
      income.currency = 'USD'

      expense.should be_is_draft
      expense.balance.should eq(100)

      income.should be_is_approved

      ep = ExpensePayment.new(payment_with_income_attributes.merge(amount: 10, interest: 1, exchange_rate: 7.0))


      ep.pay.should be_true
      # Expense
      ep.expense.balance.should == 100 - 7.0 * 10
      # Income
      ep.account_to.balance.should == 100 - 11

      ########################################
      # Inverse
      expense.balance = expense.total = 100
      income.balance = income.total = 100
      expense.currency = 'USD'
      income.currency = 'BOB'

      ep = ExpensePayment.new(payment_with_income_attributes.merge(amount: 10, interest: 1, exchange_rate: 7.0))

      ep.pay.should be_true
      # Expense
      ep.expense.balance.round(4).should == (100 - 1.0/7 * 10).round(4)
      # Income
      ep.account_to.balance.should == 100 - 11
    end
  end

  context "Pay with different currencies" do
    before(:each) do
      expense.stub(save: true)
      Expense.stub(:find_by_id).with(expense.id).and_return(expense)
      AccountLedger.any_instance.stub(save_ledger:  true)
    end

    it "uses the exchange_rate for other curerncy" do
      ac_usd = build(:cash, currency: 'USD', id: 101)
      Account.stub_chain(:active, :find_by_id).with(101).and_return(ac_usd)
      expense.balance = 100

      ep = ExpensePayment.new(valid_attributes.merge(account_to_id: 101, exchange_rate: 7.001, amount: 10, interest: 1))

      ep.pay.should be_true

      ep.amount.should == 10
      # expense
      ep.expense.currency.should eq('BOB')
      ep.expense.balance.should == (100 - 7.001 * 10).round(4)
      # ledger
      ep.ledger.should_not be_inverse
      ep.amount.should == 10
      ep.ledger.currency.should eq('USD')
      # int_ledger
      ep.int_ledger.should_not be_inverse
      ep.int_ledger.amount.should == 1
      ep.int_ledger.currency.should eq('USD')
    end

    it "Inverse when expense in USD" do
      expense.currency = 'USD'
      ac_bob = build(:cash, currency: 'BOB', id: 103, amount: 1000)
      Account.stub_chain(:active, :find_by_id).with(103).and_return(ac_bob)
      expense.balance = 100

      ep = ExpensePayment.new(valid_attributes.merge(account_to_id: 103, exchange_rate: 7.001, amount: 200, interest: 1))

      ep.pay.should be_true

      ep.amount.should == 200
      # expense
      ep.expense.currency.should eq('USD')
      ep.expense.balance.should == (100 - 1/7.001 * 200).round(4)
      # ledger
      ep.ledger.should be_inverse
      ep.amount.should == 200
      ep.ledger.currency.should eq('BOB')
      # int_ledger
      ep.int_ledger.should be_inverse
      ep.int_ledger.amount.should == 1
      ep.int_ledger.currency.should eq('BOB')
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
      AccountLedger.any_instance.stub(save_ledger: false, errors: {amount: 'Not real'})
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
