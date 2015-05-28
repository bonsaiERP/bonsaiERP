# encoding: utf-8
require 'spec_helper'

describe Expenses::Payment do
  before(:each) do
    OrganisationSession.organisation = build :organisation, currency: 'BOB'
    UserSession.user = build :user, id: 12
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
  let(:expense) do
    Expense.new(
      total: balance, balance: balance, currency: 'BOB', contact_id: contact.id, state: 'draft'
    ) {|i|
      i.id = account_id
      i.contact = contact
    }
  end
  let(:account_to) { build :account, id: account_to_id, amount: 100 }

  context 'Validations' do
    it "validates presence of expense" do
      pay_out = Expenses::Payment.new(valid_attributes)
      pay_out.should_not be_valid
      expect(pay_out.errors[:expense].present?).to eq(true)

      Expense.stub(find_by_id: expense)
      Account.stub(find_by_id: account_to)
      expect(pay_out.valid?).to eq(true)
    end

    it "does not allow amount greater than balance" do
      pay_out = Expenses::Payment.new(valid_attributes.merge(amount: 101))

      Expense.stub(find_by_id: expense)
      Account.stub(find_by_id: account_to)

      expect(pay_out.valid?).to eq(false)
      expect(pay_out.errors[:amount].present?).to eq(true)

      pay_out.amount = 100
      expect(pay_out.valid?).to eq(true)
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

      p = Expenses::Payment.new(valid_attributes)

      p.pay.should eq(true)
      p.verification.should eq(true)

      # Expense
      p.expense.should be_is_a(Expense)
      p.expense.balance.should == balance - valid_attributes[:amount]
      p.expense.should be_is_approved
      p.expense.operation_type.should eq('ledger_out')
      p.expense.approver_id.should eq(UserSession.id)

      # Ledger
      p.ledger.amount.should == -50.0
      p.ledger.exchange_rate == 1
      p.ledger.should be_is_payout
      p.ledger.account_id.should eq(expense.id)
      p.ledger.contact_id.should_not be_blank
      p.ledger.contact_id.should eq(expense.contact_id)

      # Only bank accounts are allowed to conciliate
      p.ledger.should be_is_approved
      p.ledger.reference.should eq(valid_attributes.fetch(:reference))
      p.ledger.date.should eq(valid_attributes.fetch(:date).to_date)


      # New payment to complete
      p = Expenses::Payment.new(valid_attributes.merge(amount: p.expense.balance))
      p.pay.should eq(true)

      p.expense.balance.should == 0
      p.expense.should be_is_paid
    end

    it "create ledger" do
      expense.should be_is_draft
      p = Expenses::Payment.new(valid_attributes)

      p.verification.should eq(true)

      p.pay.should eq(true)

      # ledger
      p.ledger.should be_is_a(AccountLedger)
      p.ledger.amount.should == -valid_attributes.fetch(:amount)
      p.ledger.should be_is_payout
      p.ledger.account_id.should eq(expense.id)

    end

    ### Verification only Bank accounts
    context "Verification only for bank accounts" do
      it "verificates because it is a bank" do
        bank = build :bank, id: 100
        Account.stub(:find_by_id).with(bank.id).and_return(bank)
        bank.id.should_not eq(account_to_id)

        p = Expenses::Payment.new(valid_attributes.merge(account_to_id: 100, verification: true))

        p.pay.should eq(true)
        p.should be_verification
        p.account_to_id.should eq(100)
        # Should not conciliate
        p.ledger.should be_is_pendent

        # When verification=false
        p = Expenses::Payment.new(valid_attributes.merge(account_to_id: 100, verification: false))

        p.pay.should eq(true)
        # Should conciliate
        p.ledger.should be_is_approved
      end

      it "doesn't change unless it's bank account" do
        cash = build :cash, id: 200
        Account.stub(:find_by_id).with(cash.id).and_return(cash)
        cash.id.should_not eq(account_to_id)

        Account.find_by_id(account_to_id).should eq(account_to)

        p = Expenses::Payment.new(valid_attributes.merge(account_to_id: 200, verification: true))

        p.pay.should eq(true)
        p.ledger.should be_is_approved

        # verification=false
        p = Expenses::Payment.new(valid_attributes.merge(account_to_id: 200, verification: false))

        p.pay.should eq(true)

        p.ledger.should be_is_approved
      end
    end

  end

  context "Pay with income" do
    let(:income) { Income.new(total: 200, balance: 100, state: 'approved', currency: 'BOB') {|e| e.id = 14} }

    let(:payment_with_income_attributes) {
      {
        account_id: expense.id, account_to_id: income.id, amount: 50,
        exchange_rate: 1, verification: 'true',
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
      ep = Expenses::Payment.new(payment_with_income_attributes)

      expect(ep.valid?).to eq(false)

      expect(ep.errors[:amount]).to eq([I18n.t('errors.messages.payment.income_balance')])

      income.balance = 100

      expect(ep.valid?).to eq(true)
    end

    it "updates the related Income account" do
      expense.stub(save: true)
      income.stub(save: true)
      income.balance = 100
      income.currency = 'BOB'

      bal = expense.balance

      ep = Expenses::Payment.new(payment_with_income_attributes)

      bal = expense.balance
      # Pay
      ep.pay.should eq(true)
      # Expense
      ep.expense.balance.should == bal - ep.amount
      # Expense
      ep.account_to.balance.should == 100 - ep.amount

      ep.ledger.should be_is_servin
    end

    it "should set the state of the expense when done" do
      income.state = 'draft'

      ep = Expenses::Payment.new(payment_with_income_attributes)

      ep.should_not be_valid

      expect(ep.errors[:account_to_id]).to eq([I18n.t('errors.messages.payment.invalid_income_state')])
    end

    it "sets the state for the income" do
      expense.stub(save: true)
      income.stub(save: true)
      expense.balance = expense.total = 100
      income.balance = income.total = 100

      expense.should be_is_draft
      expense.balance.should eq(100)

      income.should be_is_approved

      ep = Expenses::Payment.new(payment_with_income_attributes.merge(amount: 100))

      ep.pay.should eq(true)
      # Expense
      ep.expense.balance.should == 0
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

      ep = Expenses::Payment.new(payment_with_income_attributes.merge(amount: 10, exchange_rate: 7.0))


      ep.pay.should eq(true)
      # Expense
      ep.expense.balance.should == 100 - 7.0 * 10
      # Income
      ep.account_to.balance.should == 100 - 10

      ########################################
      # Inverse
      expense.balance = expense.total = 100
      income.balance = income.total = 100
      expense.currency = 'USD'
      income.currency = 'BOB'

      ep = Expenses::Payment.new(payment_with_income_attributes.merge(amount: 10, exchange_rate: 7.0))

      ep.pay.should eq(true)
      # Expense
      ep.expense.balance.to_f.should == (100 - 1.0/7 * 10).round(2)
      # Income
      ep.account_to.balance.should == 100 - 10
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

      ep = Expenses::Payment.new(valid_attributes.merge(account_to_id: 101, exchange_rate: 7.001, amount: 10))

      ep.pay.should eq(true)

      ep.amount.should == 10
      # expense
      ep.expense.currency.should eq('BOB')
      ep.expense.balance.should == (100 - 7.001 * 10).round(4)
      # ledger
      ep.ledger.should_not be_inverse
      ep.amount.should == 10
      ep.ledger.currency.should eq('USD')
    end

    it "Inverse when expense in USD" do
      expense.currency = 'USD'
      ac_bob = build(:cash, currency: 'BOB', id: 103, amount: 1000)
      Account.stub_chain(:active, :find_by_id).with(103).and_return(ac_bob)
      expense.balance = 100

      ep = Expenses::Payment.new(valid_attributes.merge(account_to_id: 103, exchange_rate: 7.001, amount: 200))

      ep.pay.should eq(true)

      ep.amount.should == 200
      # expense
      ep.expense.currency.should eq('USD')
      ep.expense.balance.to_f.should == (100 - 1/7.001 * 200).round(2)
      # ledger
      ep.ledger.should be_inverse
      ep.amount.should == 200
      ep.ledger.currency.should eq('BOB')
    end
  end

  context "Errors" do
    it "does not save if invalid Expenses::Payment" do
      Expense.any_instance.should_not_receive(:save)
      p = Expenses::Payment.new(valid_attributes.merge(reference: ''))
      p.pay.should eq(false)
    end

    before(:each) do
      expense.stub(save: false, errors: {balance: 'No balance'})
      Expense.stub(:find_by_id).with(account_id).and_return(expense)
      Account.stub(:find_by_id).with(account_to_id).and_return(account_to)
      AccountLedger.any_instance.stub(save_ledger: false, errors: {amount: 'Not real'})
    end

    it "sets errors from other clases" do
      p = Expenses::Payment.new(valid_attributes)

      p.pay.should eq(false)
      # There is no method Expenses::Payment#balance
      p.errors[:amount].should eq(['Not real'])
      # There is a method Expenses::Payment#amount
      p.errors[:base].should eq(['No balance'])
    end
  end
end
