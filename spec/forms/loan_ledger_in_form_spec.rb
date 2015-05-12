require 'spec_helper'

describe LoanLedgerInForm do

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

  context 'validations' do

    it 'numericality > 0' do
      lli = LoanLedgerInForm.new(account_to_id: bank.id, amount: 0)
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

    it 'loan' do
      li = LoanLedgerInForm.new(
        loan_id: loan_give.id, amount: 100, account_to_id: bank.id,
        reference: 'New loan_give', date: today
      )
      expect(bank.reload.amount).to eq(500)

      li.create
      expect(li.ledger_in.amount).to eq(-100)
      expect(li.ledger_in.persisted?).to eq(true)

      loan_give.reload

      expect(loan_give.amount).to eq(600)

      expect(bank.reload.amount).to eq(400)
    end

  end

  context 'Loans::Receive#ledger_in' do
    let(:loan_receive) {
      lg = Loans::ReceiveForm.new(loan_attributes)
      lg.create
      lg.loan
    }

    it 'loan' do
      li = LoanLedgerInForm.new(
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

  end

end
