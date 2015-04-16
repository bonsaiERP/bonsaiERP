require 'spec_helper'

describe Loans::ReceivePaymentForm do
  #it { should validate_presence_of(:reference) }

  let(:loan_attr) do
    today = Date.today
    {
      date: today, due_date: today + 10.days, total: 100,
      reference: 'Receipt 00232', contact_id: 1
    }
  end


  it "validate" do
    lp = Loans::PaymentForm.new
    lp.stub(loan: Loan.new(total: 100))
    lp.valid?
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
      Loans::Receive.any_instance.stub(contact: contact)
    }

    it "sets ledger status" do
      lp = Loans::ReceivePaymentForm.new(verification: '1', account_to_id: 2)
      lp.stub(loan: Loans::Receive.new(id: 10))
      expect(lp.ledger.present?).to eq(true)

      expect(lp.int_ledger.is_pendent?).to eq(true)
    end

    it "pays Loan" do
      lf = Loans::ReceiveForm.new(loan_attr.merge(account_to_id: cash.id))

      expect(lf.create).to eq(true)
      expect(lf.loan.persisted?).to eq(true)
      expect(lf.loan.class).to eq(Loans::Receive)
      expect(lf.loan.amount).to  eq(100)
      expect(lf.loan.total).to eq(100)
      expect(lf.loan.ledger_ins.first.is_a?(AccountLedger)).to eq(true)
      expect(lf.loan.ledger_ins.first.is_lrcre?).to eq(true)

      expect(lf.ledger.contact_id.present?).to eq(true)
      expect(lf.ledger.contact_id).to eq(lf.loan.contact_id)

      expect(cash.reload.amount).to eq(100)

      lp = Loans::ReceivePaymentForm.new(attributes.merge(account_id: lf.loan.id))

      expect(lp.create_payment).to eq(true)
      expect(lp.ledger.amount).to eq(-50)
      expect(lp.ledger.currency).to eq('BOB')
      expect(lp.ledger.is_approved?).to eq(true)

      expect(lp.ledger.contact_id.present?).to eq(true)
      expect(lp.ledger.contact_id).to eq(lf.loan.contact_id)

      loan = Loans::Receive.find(lf.loan.id)
      expect(loan.amount).to eq(50)

      c = Cash.find(cash.id)
      expect(c.amount).to eq(50)

      lp = Loans::ReceivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 60))
      expect(lp.create_payment).to eq(false)
      expect(lp.errors[:amount]).to eq([I18n.t('errors.messages.less_than_or_equal_to', count: 50.0)])
      # Pay with other currency
      bank = create :bank, currency: 'USD', amount: 0

      lp = Loans::ReceivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 25, account_to_id: bank.id, exchange_rate: 2))

      expect(lp.create_payment).to eq(true)
      loan = Loans::Receive.find(loan.id)

      expect(loan.amount).to eq(0)
      expect(loan.is_paid?).to eq(true)
    end

    # Pay with income
    it "pay with income" do
      lf = Loans::ReceiveForm.new(loan_attr.merge(account_to_id: cash.id, total: 200))

      expect(lf.create).to eq(true)
      expect(lf.loan.amount).to eq(200)
      expect(lf.loan.is_approved?).to eq(true)

      today = Date.today
      income = Income.new(total: 100, balance: 100, state: 'approved', currency: 'BOB', id: 100, contact_id: 1,
                         date: today, due_date: today, ref_number: 'I-13-0001')
      Income.any_instance.stub(contact: build(:contact, id: 1))
      expect(income.save).to eq(true)

      lp = Loans::ReceivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 200, account_to_id: income.id))

      # Validate for income amount
      expect(lp.create_payment).to eq(false)
      expect(lp.errors[:amount]).to eq(['La cantidad es mayor que el saldo del Ingreso'])


      lp.amount = 100
      expect(lp.create_payment).to eq(true)

      inc = Income.find(income.id)
      expect(inc.amount).to eq(0)
      expect(inc.is_paid?).to eq(true)

      l = Loans::Receive.find(lf.loan.id)
      expect(l.amount).to eq(100)
      expect(l.is_approved?).to eq(true)

      lp = Loans::ReceivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 200, account_to_id: cash.id))
      expect(lp.create_payment).to eq(false)

      expect(lp.errors[:amount]).to_not be_blank
    end


    it "pays interest" do
      lf = Loans::ReceiveForm.new(loan_attr.merge(account_to_id: cash.id))

      expect(lf.create).to eq(true)
      expect(lf.loan).to be_persisted
      expect(lf.loan.ledger_ins.first.class).to eq(AccountLedger)
      expect(cash.reload.amount).to eq(100)

      lp = Loans::ReceivePaymentForm.new(attributes.merge(account_id: lf.loan.id))

      expect(lp.create_interest).to eq(true)
      expect(lp.int_ledger.amount).to eq(-50)
      expect(lp.int_ledger.is_lrint?).to eq(true)
      expect(lp.int_ledger.persisted?).to eq(true)

      expect(lp.int_ledger.contact_id.present?).to eq(true)
      expect(lp.int_ledger.contact_id).to eq(lf.loan.contact_id)

      loan = Loans::Receive.find(lf.loan.id)
      expect(loan.interests).to eq(50)

      c = Cash.find(cash.id)
      expect(c.amount).to eq(50)
    end

    # Pay with INTERESTS with income
    it "pay INTERESTS with income" do
      lf = Loans::ReceiveForm.new(loan_attr.merge(account_to_id: cash.id, total: 200))

      expect(lf.create).to eq(true)
      expect(lf.loan.amount).to eq(200)
      expect(lf.loan).to be_is_approved

      today = Date.today
      income = Income.new(total: 100, balance: 100, state: 'approved', currency: 'BOB', id: 100, contact_id: 1,
                         date: today, due_date: today, ref_number: 'I-13-001')
      Income.any_instance.stub(contact: build(:contact, id: 1))
      expect(income.save).to eq(true)

      lp = Loans::ReceivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 200, account_to_id: income.id))

      expect(lp.create_interest).to eq(false)
      lp.amount = 100

      expect(lp.create_interest).to eq(true)
      expect(lp.int_ledger).to be_persisted
      expect(lp.int_ledger.amount).to eq(-100)
      expect(lp.int_ledger).to be_is_lrint

      inc = Income.find(income.id)
      expect(inc.amount).to eq(0)
      expect(inc).to be_is_paid

      # No changes to the amount
      l = Loans::Receive.find(lf.loan.id)
      expect(l.amount).to eq(200)
      expect(l).to be_is_approved
    end

    context 'other currencies' do
      let(:cash2) { create :cash, currency: 'USD', amount: 0 }

      it 'USD and BOB' do
        lf = Loans::ReceiveForm.new(loan_attr.merge(account_to_id: cash2.id))

        expect(lf.create).to eq(true)
        expect(lf.loan).to be_persisted
        expect(lf.loan.class).to eq(Loans::Receive)
        expect(lf.loan.amount).to eq(100)
        expect(lf.loan.total).to eq(100)
        expect(lf.loan.currency).to eq('USD')
        expect(lf.loan.ledger_ins.first.class).to eq(AccountLedger)
        expect(lf.loan.ledger_ins.first.is_lrcre?).to eq(true)
        expect(cash2.reload.amount).to eq(100)

        lp = Loans::ReceivePaymentForm.new(attributes.merge(account_id: lf.loan.id, exchange_rate: 5))

        expect(lp.create_payment).to eq(true)
        expect(lp.ledger.amount).to eq(-50)
        expect(lp.ledger.currency).to eq('BOB')

        loan = Loans::Receive.find(lf.loan.id)
        expect(loan.amount).to eq(90)

        c = Cash.find(cash.id)
        expect(c.amount).to eq(-50)

        lp = Loans::ReceivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 95, account_to_id: cash2.id))
        expect(lp.create_payment).to eq(false)
        expect(lp.errors[:amount]).to eq([I18n.t('errors.messages.less_than_or_equal_to', count: 90.0)])

        # Pay in USD

        lp = Loans::ReceivePaymentForm.new(attributes.merge(account_id: lf.loan.id, amount: 90, account_to_id: cash2.id))

        expect(lp.create_payment).to eq(true)
        loan = Loans::Receive.find(loan.id)

        expect(loan.amount).to eq(0)
        expect(loan.is_paid?).to eq(true)
      end
    end

  end

end
