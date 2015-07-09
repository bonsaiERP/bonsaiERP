require 'spec_helper'

describe Loans::LedgerInForm do

  let(:user) { build :user, id: 1 }
  let(:contact) { create :contact, matchcode: 'James Brown' }

  before(:each) do
    UserSession.user = user
  end

  let(:bank) { create :bank, amount: 1000 }
  let(:today) { Date.today }
  let(:loan_attributes)  {
    {
      date: today, due_date: today + 10.days, total: 500, account_to_id: bank.id,
      reference: 'Receipt 00232', contact_id: contact.id, description: 'New loan'
    }
  }

  it 'no params' do
    lli = Loans::LedgerInForm.new

    expect(lli.create).to eq(false)
  end

  context 'validations' do

    it { should validate_presence_of(:account_to_id) }
    it { should validate_presence_of(:reference) }

    it 'numericality > 0' do
      lli = Loans::LedgerInForm.new(account_to_id: bank.id, amount: 0, reference: 'New amount')
      expect(lli.valid?).to eq(false)
      expect(lli.errors[:amount].present?).to eq(true)

      lli.amount = 10
      expect(lli.valid?).to eq(true)
    end

  end

  context 'Loans::Give#ledger_in' do
    let(:loan_give) {
      lg = Loans::GiveForm.new(loan_attributes)
      lg.create
      lg.loan
    }

    it 'loan verification=false' do
      li = Loans::LedgerInForm.new(
        loan_id: loan_give.id, amount: 100, account_to_id: bank.id,
        reference: 'New loan_give', date: today, verification: false
      )
      expect(bank.reload.amount).to eq(500)
      expect(loan_give.total).to eq(500)

      li.create
      expect(li.loan)

      expect(li.ledger_in.amount).to eq(-100)
      expect(li.ledger_in.exchange_rate).to eq(1)
      expect(li.ledger_in.status).to eq('approved')
      expect(li.ledger_in.persisted?).to eq(true)

      loan_give.reload

      expect(loan_give.amount).to eq(600)
      expect(loan_give.total).to eq(600)

      expect(bank.reload.amount).to eq(400)
    end

    it 'loan verification=true' do
      li = Loans::LedgerInForm.new(
        loan_id: loan_give.id, amount: 100, account_to_id: bank.id,
        reference: 'New loan_give', date: today, verification: true
      )
      expect(bank.reload.amount).to eq(500)

      li.create
      expect(li.ledger_in.amount).to eq(-100)
      expect(li.ledger_in.exchange_rate).to eq(1)
      expect(li.ledger_in.status).to eq('pendent')
      expect(li.ledger_in.persisted?).to eq(true)

      loan_give.reload

      expect(loan_give.amount).to eq(600)

      expect(bank.reload.amount).to eq(500)
    end

    it 'loan exchange_rate=2' do
      bank2 = create :bank, currency: 'USD', amount: 100, name: 'Bank USD'

      li = Loans::LedgerInForm.new(
        loan_id: loan_give.id, amount: 75, account_to_id: bank2.id,
        reference: 'New loan_give', date: today, verification: false, exchange_rate: 2
      )
      expect(bank2.reload.amount).to eq(100)

      li.create

      expect(li.ledger_in.amount).to eq(-75)
      expect(li.ledger_in.exchange_rate).to eq(2)
      expect(li.ledger_in.status).to eq('approved')
      expect(li.ledger_in.persisted?).to eq(true)

      loan_give.reload

      expect(loan_give.amount).to eq(650)

      expect(bank2.reload.amount).to eq(25)
    end

  end

  context 'Loans::Receive#ledger_in' do
    let(:loan_receive) {
      lg = Loans::ReceiveForm.new(loan_attributes)
      lg.create
      lg.loan
    }

    it 'loan' do
      li = Loans::LedgerInForm.new(
        loan_id: loan_receive.id, amount: 100, account_to_id: bank.id,
        reference: 'New loan_receive', date: today
      )
      expect(bank.reload.amount).to eq(1500)

      li.create
      expect(li.ledger_in.amount).to eq(100)
      expect(li.ledger_in.persisted?).to eq(true)

      loan_receive.reload

      expect(loan_receive.amount).to eq(600)

      expect(bank.reload.amount).to eq(1600)
    end

    it 'loan exchange_rate=2' do
      bank2 = create :bank, currency: 'USD', amount: 100, name: 'Bank USD'

      li = Loans::LedgerInForm.new(
        loan_id: loan_receive.id, amount: 75, account_to_id: bank2.id,
        reference: 'New loan_receive', date: today, verification: false, exchange_rate: 2
      )
      expect(bank2.reload.amount).to eq(100)

      li.create

      expect(li.ledger_in.amount).to eq(75)
      expect(li.ledger_in.exchange_rate).to eq(2)
      expect(li.ledger_in.status).to eq('approved')
      expect(li.ledger_in.persisted?).to eq(true)

      loan_receive.reload

      expect(loan_receive.amount).to eq(650)

      expect(bank2.reload.amount).to eq(175)
    end

  end

end
