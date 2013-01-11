# encoding: utf-8
require 'spec_helper'

describe AccountLedger do
  let(:valid_attributes) do
    {
      date: Date.today, operation: "payin", reference: "Income",
      amount: 100, currency: 'BOB', exchange_rate: 1,
      account_id: 2, to_id: 1
    }
  end

  it { should have_valid(:operation).when( *AccountLedger::OPERATIONS ) }
  it { should_not have_valid(:operation).when('no', 'ok') }
  it { should have_valid(:amount).when(0.25, -0.25) }
  it { should_not have_valid(:amount).when('', nil) }
  it { should have_valid(:exchange_rate).when(0.25, 10) }
  it { should_not have_valid(:exchange_rate).when(0.0, -1.2, '', nil) }

  it 'assing currency based on the account' do
    account = build :account, id: 1, currency: 'USD'
    a = AccountLedger.new(valid_attributes)
    a.currency.should eq('BOB')
    a.stub(account: account)

    a.should be_valid
    a.currency.should eq('USD')
  end

  context 'Creator Approver' do
    let(:account) { build :account, id: 11, amount: 0.0 }

    let(:attributes) { valid_attributes.merge(account_id: 11, to_id: nil) }

    before(:each) do
      UserSession.current_user = build :user, id: 10
    end

    it "assigns the creator in creatios" do
      al = AccountLedger.new(attributes.merge(conciliation: false, amount: 100.0))
      al.stub(account: account)
      al.save.should be_true

      al.should be_persisted
      al.creator_id.should eq(10)
      al.approver_id.should be_nil
      account.amount.should == 0.0

      # Check approver
      Account.any_instance.stub(save: true)
      UserSession.stub(user_id: 20)
      al.conciliation = true
      al.save.should be_true
      al.approver_id.should eq(20)

      account.amount.should == 100.0
    end
  end

end
