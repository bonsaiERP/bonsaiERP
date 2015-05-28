# encoding: utf-8
require 'spec_helper'

describe Incomes::Payment do

  before(:each) do
    OrganisationSession.organisation = build :organisation, currency: 'BOB'
    UserSession.user = build :user, id: 10
  end

  let(:valid_attributes) {
    {
      account_id: 10, account_to_id: 2, exchange_rate: 1,
      amount: 50, reference: 'El primer pago',
      verification: 'true', date: Date.today
    }
  }
  let(:balance) { 100.0 }

  let(:account_id) { valid_attributes.fetch(:account_id) }
  let(:account_to_id) { valid_attributes.fetch(:account_to_id) }

  let(:contact) { build :contact, id: 11 }
  let(:income) do
    Income.new(
      total: balance, balance: balance, currency: 'BOB', contact_id: contact.id, state: 'draft'
    ) {|i|
      i.id = account_id
      i.contact = contact
    }
  end
  let(:account_to) { build :account, id: account_to_id, amount: 100 }

  context 'Validations' do
    it "validates presence of income" do
      pay_in = Incomes::Payment.new(valid_attributes)
      pay_in.should_not be_valid
      expect(pay_in.errors[:income].present?).to eq(true)

      Income.stub(find_by_id: income)
      Account.stub(find_by_id: account_to)
      expect(pay_in.valid?).to eq(true)
    end


    let(:bank) { build(:bank, currency: 'USD', id: 102) }

    # There purpose is to return change
    # there is a balance of 50 BOB and someone pays with a
    # 20 USD bill (ER 1 USD = 6.95 BOB), then we have to return change
    it "allows amount greater than balance" do
      pay_in = Incomes::Payment.new(valid_attributes.merge(account_to_id: 102, exchange_rate: 4, amount: 50))

      ConciliateAccount.any_instance.stub(conciliate!: true)
      Income.stub(find_by_id: income)
      Income.any_instance.stub(save: true)
      Account.stub(find_by_id: bank)
      AccountLedger.any_instance.stub(save: true)

      expect(income.valid?).to eq(false)

      expect(pay_in.pay).to eq(true)

      pay_in.income.should be_has_error
      pay_in.income.error_messages.should eq({ "balance" => ['movement.negative_balance']})
    end

    it "does not allow greater values for the same currency" do
      pay_in = Incomes::Payment.new(valid_attributes.merge(amount: 101))

      ConciliateAccount.any_instance.stub(conciliate!: true)
      Income.stub(find_by_id: income)
      Income.any_instance.stub(save: true)
      Account.stub(find_by_id: account_to)
      AccountLedger.any_instance.stub(save: true)

      expect(pay_in.pay).to eq(false)
      pay_in.errors[:amount].should eq([I18n.t('errors.messages.payment.balance')])
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
      expect(income.is_draft?).to eq(true)
      expect(income.approver_id).to eq(nil)

      p = Incomes::Payment.new(valid_attributes)

      expect(p.pay).to eq(true)
      expect(p.verification).to eq(true)

      # Income
      expect(p.income).to be_is_a(Income)
      expect(p.income.balance).to eq(balance - valid_attributes[:amount])
      expect(p.income.is_approved?).to eq(true)
      expect(p.income.approver_id).to eq(UserSession.id)
      expect(p.income.operation_type).to eq('ledger_in')

      # Ledger
      p.ledger.amount.should == 50.0
      p.ledger.exchange_rate == 1
      p.ledger.should be_is_payin
      p.ledger.account_id.should eq(income.id)

      p.ledger.contact_id.should_not be_blank
      p.ledger.contact_id.should eq(p.income.contact_id)

      # Only bank accounts are allowed to conciliate
      p.ledger.should be_is_approved
      p.ledger.reference.should eq(valid_attributes.fetch(:reference))
      p.ledger.date.should eq(valid_attributes.fetch(:date).to_date)

      # New payment to complete
      p = Incomes::Payment.new(valid_attributes.merge(amount: p.income.balance))
      p.pay.should eq(true)

      p.income.balance.should == 0
      p.income.should be_is_paid
    end

    it "create ledger" do
      income.should be_is_draft
      p = Incomes::Payment.new(valid_attributes)

      p.verification.should eq(true)

      p.pay.should eq(true)

      # ledger
      p.ledger.should be_is_approved
      p.ledger.should be_is_a(AccountLedger)
      p.ledger.amount.should == valid_attributes.fetch(:amount)
      p.ledger.should be_is_payin
      p.ledger.account_id.should eq(income.id)
    end

    ### Verification only Bank accounts
    context "Verification only for bank accounts" do
      it "verificates because it is a bank" do
        bank = build :bank, id: 100
        Account.stub(:find_by_id).with(bank.id).and_return(bank)
        bank.id.should_not eq(account_to_id)

        p = Incomes::Payment.new(valid_attributes.merge(account_to_id: 100, verification: true))

        p.pay.should eq(true)
        p.should be_verification
        p.account_to_id.should eq(100)
        # Should not conciliate
        p.ledger.should be_is_pendent

        # When verification=false
        p = Incomes::Payment.new(valid_attributes.merge(account_to_id: 100, verification: false))

        p.pay.should eq(true)
        # Should conciliate
        p.ledger.should be_is_approved
      end

      it "doesn't change unless it's bank account" do
        cash = build :cash, id: 200
        Account.stub(:find_by_id).with(cash.id).and_return(cash)
        cash.id.should_not eq(account_to_id)

        Account.find_by_id(account_to_id).should eq(account_to)

        p = Incomes::Payment.new(valid_attributes.merge(account_to_id: 200, verification: true))

        p.pay.should eq(true)

        p.ledger.should be_is_approved

        #inverse
        p = Incomes::Payment.new(valid_attributes.merge(account_to_id: 200, verification: false))

        p.pay.should eq(true)

        p.ledger.should be_is_approved
      end
    end
  end

  context "Pay with expense" do
    let(:expense) { Expense.new(total: 200, balance: 100, state: 'approved', currency: 'BOB') {|e| e.id = 14} }

    let(:payment_with_expense_attributes) {
      {
        account_id: income.id, account_to_id: expense.id, amount: 50,
        exchange_rate: 1, verification: 'true',
        date: Date.today, reference: 'Pay with expense'
      }
    }

    before(:each) do
      Account.stub(:find_by_id).with(income.id).and_return(income)
      Account.stub(:find_by_id).with(expense.id).and_return(expense)
      AccountLedger.any_instance.stub(save_ledger: true)
    end

    it "is not valid when amount is greater than expense balance" do
      expense.balance = 20
      ip = Incomes::Payment.new(payment_with_expense_attributes)

      expect(ip.valid?).to eq(false)

      expect(ip.errors[:amount]).to eq([I18n.t('errors.messages.payment.expense_balance')])

      expense.balance = 100

      expect(ip.valid?).to eq(true)
    end

    it "updates the related Expense account" do
      income.stub(save: true)
      expense.stub(save: true)
      expense.balance = 100
      expense.currency = 'BOB'

      bal = income.balance

      ip = Incomes::Payment.new(payment_with_expense_attributes)

      bal = income.balance
      # Pay
      ip.pay.should eq(true)
      # Income
      ip.income.balance.should == bal - ip.amount
      # Expense
      ip.account_to.balance.should == 100 - ip.amount

      ip.ledger.should be_is_servex
    end

    it "should set the state of the expense when done" do
      expense.state = 'draft'

      ip = Incomes::Payment.new(payment_with_expense_attributes)

      expect(ip.valid?).to eq(false)

      expect(ip.errors[:account_to_id]).to eq([I18n.t('errors.messages.payment.invalid_expense_state')])
    end

    it "sets the state for the expense" do
      income.stub(save: true)
      expense.stub(save: true)
      income.balance = income.total = 100
      expense.balance = expense.total = 100

      income.should be_is_draft
      income.balance.should eq(100)

      expense.should be_is_approved

      ip = Incomes::Payment.new(payment_with_expense_attributes.merge(amount: 100))

      ip.pay.should eq(true)
      # Income
      ip.income.balance.should == 0
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

      ip = Incomes::Payment.new(payment_with_expense_attributes.merge(amount: 10, exchange_rate: 7.0))

      ip.pay.should eq(true)
      # Income
      ip.income.balance.should == 100 - 7.0 * 10
      # Expense
      ip.account_to.balance.should == 100 - 10

      ########################################
      # Inverse
      income.balance = income.total = 100
      expense.balance = expense.total = 100
      income.currency = 'USD'
      expense.currency = 'BOB'

      ip = Incomes::Payment.new(payment_with_expense_attributes.merge(amount: 10, exchange_rate: 7.0))

      ip.pay.should eq(true)
      # Income
      ip.income.balance.to_f.should == (100 - 1.0/7 * 10).round(2)
      # Expense
      ip.account_to.balance.should == 100 - 10
    end
  end

  context "Pay with different currencies" do
    before(:each) do
      income.stub(save: true)
      Income.stub(:find_by_id).with(income.id).and_return(income)
      AccountLedger.any_instance.stub(save_ledger:  true)
    end

    it "uses the exchange_rate for other curerncy" do
      ac_usd = build(:cash, currency: 'USD', id: 101)
      Account.stub_chain(:active, :find_by_id).with(101).and_return(ac_usd)
      income.balance = 100

      ip = Incomes::Payment.new(valid_attributes.merge(account_to_id: 101, exchange_rate: 7.001, amount: 10))

      ip.pay.should eq(true)

      ip.amount.should == 10
      # income
      ip.income.currency.should eq('BOB')
      ip.income.balance.should == (100 - 7.001 * 10).round(4)
      # ledger
      ip.ledger.should_not be_inverse
      ip.amount.should == 10
      ip.ledger.currency.should eq('USD')
    end

    it "Inverse when income in USD" do
      income.currency = 'USD'
      ac_bob = build(:cash, currency: 'BOB', id: 103)
      Account.stub_chain(:active, :find_by_id).with(103).and_return(ac_bob)
      income.balance = 100

      ip = Incomes::Payment.new(valid_attributes.merge(account_to_id: 103, exchange_rate: 7.001, amount: 200))

      ip.pay.should eq(true)

      ip.amount.should == 200
      # income
      ip.income.currency.should eq('USD')
      ip.income.balance.to_f.should == (100 - 1/7.001 * 200).round(2)
      # ledger
      ip.ledger.should be_inverse
      ip.amount.should == 200
      ip.ledger.currency.should eq('BOB')
    end
  end

  context "Errors" do
    it "does not save if invalid Incomes::Payment" do
      Income.any_instance.should_not_receive(:save)
      p = Incomes::Payment.new(valid_attributes.merge(reference: ''))
      p.pay.should eq(false)
    end

    before(:each) do
      income.stub(save: false, errors: {balance: 'No balance'})
      Income.stub(:find_by_id).with(account_id).and_return(income)
      Account.stub(:find_by_id).with(account_to_id).and_return(account_to)
      AccountLedger.any_instance.stub(save_ledger: false, errors: {amount: 'Not real'})
    end

    it "sets errors from other clases" do
      p = Incomes::Payment.new(valid_attributes)

      p.pay.should eq(false)
      # There is no method Incomes::Payment#balance
      p.errors[:amount].should eq(['Not real'])
      # There is a method Incomes::Payment#amount
      p.errors[:base].should eq(['No balance'])
    end
  end
end
