require 'spec_helper'

describe Loans::GivePaymentForm do
  #it { should validate_presence_of(:reference) }

  let(:loan_attr) do
    today = Date.today
    {
      date: today, due_date: today + 10.days, total: 100,
      reference: 'Receipt 00232', contact_id: 1
    }
  end

  context 'payment' do
    let(:cash) { create :cash, currency: 'BOB', amount: 0 }
    let(:contact) { build :contact, id: 1 }

    let(:attributes) do
      {
        account_to_id: cash.id, date: Date.today, reference: 'Pay 23233',
        amount: 50, exchange_rate: 1
      }
    end

    before(:each) {
      UserSession.user = build :user, id: 1
      OrganisationSession.organisation = build :organisation, currency: 'BOB'
      Loans::Give.any_instance.stub(contact: contact)
    }

    it "sets ledger status" do
      lp = Loans::GivePaymentForm.new(verification: '1', account_to_id: 2)
      lp.stub(loan: Loans::Give.new(id: 10))
      lp.ledger.should be_is_pendent

      lp.int_ledger.should be_is_pendent
    end

    it "pays Loan" do
      lf = Loans::GiveForm.new(loan_attr.merge(account_to_id: cash.id))

      lf.create.should eq(true)

      lf.loan.should be_persisted
      lf.loan.should be_is_a(Loans::Give)
      lf.loan.amount.should == 100
      lf.loan.total.should == 100
      expect(lf.loan.ledger_ins.first.class).to eq(AccountLedger)
      cash.reload.amount.should == -100
      lp = Loans::GivePaymentForm.new(attributes.merge(account_id: lf.loan.id))

      lp.create_payment.should eq(true)
      lp.ledger.amount.should == 50
      lp.ledger.currency.should eq('BOB')
      lp.ledger.contact_id.should_not be_blank
      lp.ledger.contact_id.should eq(lf.loan.contact_id)
      lp.ledger.should be_is_approved

      loan = Loans::Give.find(lf.loan.id)
      loan.amount.should == 50

      c = Cash.find(cash.id)
      c.amount.should == -50

      lp = Loans::GivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 60))
      lp.create_payment.should eq(false)
      lp.errors[:amount].should eq([I18n.t('errors.messages.less_than_or_equal_to', count: 50.0)])
      # Pay with other currency
      bank = create :bank, currency: 'USD', amount: 0

      lp = Loans::GivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 25, account_to_id: bank.id, exchange_rate: 2))

      lp.create_payment.should eq(true)
      loan = Loans::Give.find(loan.id)

      loan.amount.should == 0
      loan.should be_is_paid
    end

    # Pay with expense
    it "pay with expense" do
      lf = Loans::GiveForm.new(loan_attr.merge(account_to_id: cash.id, total: 200))

      lf.create.should eq(true)
      lf.loan.amount.should == 200
      lf.loan.should be_is_approved

      today = Date.today
      expense = Expense.new(total: 100, balance: 100, state: 'approved', currency: 'BOB', id: 100, contact_id: 1,
                         date: today, due_date: today, ref_number: 'E-13-0001')
      Expense.any_instance.stub(contact: build(:contact, id: 1))
      expense.save.should eq(true)

      lp = Loans::GivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 200, account_to_id: expense.id))

      lp.create_payment.should eq(false)
      lp.amount = 100

      lp.create_payment.should eq(true)

      exp = Expense.find(expense.id)
      exp.amount.should == 0
      exp.should be_is_paid

      l = Loans::Give.find(lf.loan.id)
      l.amount.should == 100
      l.should be_is_approved

      # Error
      lp = Loans::GivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 200, account_to_id: cash.id))
      lp.create_payment.should eq(false)
      lp.errors[:amount].should_not be_blank

      lp = Loans::GivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 100, account_to_id: cash.id))
      lp.create_payment.should eq(true)

      l = Loans::Give.find(lf.loan.id)
      l.amount.should == 0
      l.should be_is_paid
    end


    it "pays interest" do
      lf = Loans::GiveForm.new(loan_attr.merge(account_to_id: cash.id))

      lf.create.should eq(true)
      lf.loan.should be_persisted
      expect(lf.loan.ledger_ins.first.class).to eq(AccountLedger)
      cash.reload.amount.should == -100

      lp = Loans::GivePaymentForm.new(attributes.merge(account_id: lf.loan.id))

      lp.create_interest.should eq(true)
      lp.int_ledger.should be_persisted
      lp.int_ledger.amount.should == 50
      lp.int_ledger.should be_is_lgint

      lp.int_ledger.contact_id.should_not be_blank
      lp.int_ledger.contact_id.should eq(lf.loan.contact_id)

      loan = Loans::Give.find(lf.loan.id)
      loan.interests.should == 50

      c = Cash.find(cash.id)
      c.amount.should == -50
    end

    # Pay with expense
    it "pay INTERESTS with expense" do
      lf = Loans::GiveForm.new(loan_attr.merge(account_to_id: cash.id, total: 200))

      lf.create.should eq(true)
      lf.loan.amount.should == 200
      lf.loan.should be_is_approved

      today = Date.today
      expense = Expense.new(total: 100, balance: 100, state: 'approved', currency: 'BOB', id: 100, contact_id: 1,
                         date: today, due_date: today, ref_number: 'E-13-0001')
      Expense.any_instance.stub(contact: build(:contact, id: 1))
      expense.save.should eq(true)

      lp = Loans::GivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 200, account_to_id: expense.id))

      lp.create_interest.should eq(false)
      lp.amount = 100

      lp.create_interest.should eq(true)
      lp.int_ledger.should be_persisted
      lp.int_ledger.amount.should == 100
      lp.int_ledger.should be_is_lgint

      exp = Expense.find(expense.id)
      exp.amount.should == 0
      exp.should be_is_paid

      # No changes to the amount
      l = Loans::Give.find(lf.loan.id)
      l.amount.should == 200
      l.should be_is_approved
    end

    context 'other currencies' do
      let(:cash2) { create :cash, currency: 'USD', amount: 0 }

      it 'USD and BOB' do
        lf = Loans::GiveForm.new(loan_attr.merge(account_to_id: cash2.id))

        lf.create.should eq(true)
        lf.loan.should be_persisted
        lf.loan.should be_is_a(Loans::Give)
        lf.loan.amount.should == 100
        lf.loan.total.should == 100
        lf.loan.currency.should eq('USD')
        expect(lf.loan.ledger_ins.first.class).to eq(AccountLedger)
        expect(lf.loan.ledger_ins.first.is_lgcre?).to eq(true)
        cash2.reload.amount.should == -100

        lp = Loans::GivePaymentForm.new(attributes.merge(account_id: lf.loan.id, exchange_rate: 5))

        lp.create_payment.should eq(true)
        lp.ledger.amount.should == 50
        lp.ledger.currency.should eq('BOB')
        lp.ledger.exchange_rate.should == 5

        loan = Loans::Receive.find(lf.loan.id)
        loan.amount.should == 90

        c = Cash.find(cash.id)
        c.amount.should == 50

        lp = Loans::GivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 95, account_to_id: cash2.id))
        lp.create_payment.should eq(false)
        lp.errors[:amount].should eq([I18n.t('errors.messages.less_than_or_equal_to', count: 90.0)])

        # Pay in USD

        lp = Loans::GivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 90, account_to_id: cash2.id))

        lp.create_payment.should eq(true)
        lp.ledger.currency.should eq('USD')
        lp.ledger.should be_persisted

        loan = Loans::Give.find(loan.id)

        loan.amount.should == 0
        loan.should be_is_paid
        cash2.reload

        cash2.amount.should == -10
      end
    end

  end
end
