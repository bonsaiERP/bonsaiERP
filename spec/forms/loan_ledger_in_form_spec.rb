require 'spec_helper'

describe LoanLedgerInForm do

  let(:user) { build :user, id: 1 }

  before(:each) do
    UserSession.user = user
  end

  let(:bank) { create :bank, amount: 100 }

  context 'validations' do

    it 'numericality > 0' do
      lli = LoanLedgerInForm.new(account_to_id: bank.id, amount: 0)
      expect(lli.valid?).to eq(false)
      expect(lli.errors[:amount].present?).to eq(true)

      lli.amount = 10
      expect(lli.valid?).to eq(true)
    end

  end
end
