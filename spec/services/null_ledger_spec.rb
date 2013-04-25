require 'spec_helper'

describe NullLedger do
  let(:income) { Income.new_income(total: 100, amount: 50, currency: 'BOB', exchange_rate: 1) }

  let(:bank) { build :bank, amount: 10, currency: 'BOB' }

  describe 'Update' do
    before(:each) do
      Income.any_instance.stub(save: true)
      AccountLedger.any_instance.stub(save: true)
      OrganisationSession.organisation = build(:organisation, currency: 'BOB')
      UserSession.user = build(:user, id: 50)
    end

    it "#null income" do
      ledger = AccountLedger.new(amount: 50, account: income, account_to: bank, conciliation: false, exchange_rate: 1)

      nl = NullLedger.new(ledger)

      nl.null_ledger.should be_true

      ledger.account.amount.should == 100
      ledger.nuller_id.should eq(50)
      ledger.nuller_datetime.should be_is_a(Time)
    end
  end
end
