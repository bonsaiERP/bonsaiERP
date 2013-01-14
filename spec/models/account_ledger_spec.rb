# encoding: utf-8
require 'spec_helper'

describe AccountLedger do

  let(:account) { build :account, id: 1, currency: 'BOB' }
  let(:account2) { build :account, id: 2, currency: 'BOB' }

  let(:valid_attributes) do
    {
      date: Date.today, operation: "payin", reference: "Income",
      amount: 100, exchange_rate: 1,
      account_id: 1, account_to_id: 2
    }
  end

  describe "Validations" do
    subject { 
      al = AccountLedger.new valid_attributes
      al.account, al.account_to = account, account2
      al
    }

    it { should have_valid(:operation).when( *AccountLedger::OPERATIONS ) }
    it { should_not have_valid(:operation).when('no', 'ok') }
    it { should have_valid(:amount).when(0.25, -0.25) }
    it { should_not have_valid(:amount).when('', nil) }
    it { should have_valid(:exchange_rate).when(0.25, 10) }
    it { should_not have_valid(:exchange_rate).when(0.0, -1.2, '', nil) }

    it "does not allow the same account" do
      subject.account_to_id = account.id

      subject.should_not be_valid
      subject.errors_on(:account_to_id).should_not be_empty
    end
  end

  it 'assings currency based on the account' do
    a = AccountLedger.new(valid_attributes)
    a.currency.should be_nil
    a.stub(account: account, account_to: account2)

    a.should be_valid
    a.currency.should eq('BOB')
  end

  context 'Creator Approver' do
    let(:account) { build :account, id: 11, amount: 0.0 }

    before(:each) do
      UserSession.user = build :user, id: 10
    end

    #it "assigns the creator when creating" do
    #  al = AccountLedger.new(valid_attributes.merge(conciliation: false, amount: 100.0))
    #  al.account = account
    #  al.account_to = account2
    #  al.save.should be_true

    #  al.should be_persisted
    #  al.creator_id.should eq(10)
    #  al.approver_id.should be_nil
    #  account.amount.should == 0.0

    #  # Check approver
    #  Account.any_instance.stub(save: true)
    #  UserSession.stub(user_id: 20)
    #  al.conciliation = true
    #  al.save.should be_true
    #  al.approver_id.should eq(20)

    #  account.amount.should == 100.0
    #end
  end

end
