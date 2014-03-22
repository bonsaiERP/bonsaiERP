require 'spec_helper'
require 'action_view'
require 'resubject/rspec'

describe AccountLedgerPresenter do
  let(:account1) { build :account, currency: 'USD', id: 1 }
  let(:account2) { build :account, currency: 'BOB', id: 2 }

  before(:each) do
    OrganisationSession.stub(currency: 'BOB')
  end

  it "#amount_ref" do
    al = build :account_ledger, amount: 700, currency: 'BOB',
      exchange_rate: 7, account_id: 1, account_to_id: 2,
      operation: 'payin'

    al.account = account1
    al.account_to = account2

    ap = AccountLedgerPresenter.new(al)
    ap.current_account_id = 1

    # For current_account_id == account_id
    ap.amount_ref.should == 100.0
    ap.currency_ref.should eq('USD')

    # For current_account_id == account_to_id
    ap.current_account_id = 2
    ap.amount_ref.should == 700.0
    ap.currency_ref.should eq('BOB')
  end

  it "#amount_ref" do
    al = build :account_ledger, amount: 100, currency: 'USD',
      exchange_rate: 7, account_id: 2, account_to_id: 1,
      operation: 'payin'

    al.account = account2
    al.account_to = account1

    ap = AccountLedgerPresenter.new(al)
    ap.current_account_id = 1

    # For current_account_id == account_id
    ap.amount_ref.should == 100.0
    ap.currency_ref.should eq('USD')

    # For current_account_id == account_to_id
    ap.current_account_id = 2
    ap.amount_ref.should == 700.0
    ap.currency_ref.should eq('BOB')
  end
end
