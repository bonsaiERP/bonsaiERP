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

  it "define_method for OPERATIONS" do
    ledger = AccountLedger.new

    AccountLedger::OPERATIONS.each do |op|
      ledger.operation = op
      ledger.should send(:"be_is_#{op}")
    end
  end

  it 'assings currency based on the account_to' do
    a = AccountLedger.new(valid_attributes)
    a.currency.should be_nil
    a.stub(account: account, account_to: account2)

    a.should be_valid
    a.currency.should eq('BOB')
  end

  context "save_ledger" do
    it "Creates a new instance of Conciliation" do
      ledger = build :account_ledger
      ledger.should be_conciliation

      # Check ConciliateAccount#conciliate
      ConciliateAccount.method_defined?(:conciliate).should be_true
      #stub
      ConciliateAccount.any_instance.should_receive(:conciliate).and_return( true)
      ledger.should_not_receive(:save)


      ledger.save_ledger.should be_true
    end

    it "Saves directly" do
      ledger = build :account_ledger

      ledger.conciliation = false

      ledger.should_receive(:save).and_return(:false)

      ledger.save_ledger.should be_true
    end
  end

  context 'Creator Approver' do
    let(:account) { build :account, id: 11, amount: 0.0 }

    before(:each) do
      UserSession.user = build :user, id: 10
    end
  end

  context 'exchange_rate' do
    before do
      OrganisationSession.organisation = build :organisation, currency: 'BOB'
    end

    let(:ac_bob) { build :cash, currency: 'BOB' }
    let(:ac_usd) { build :cash, currency: 'USD' }

    subject{ AccountLedger.new(amount: 100, currency:'BOB') }

    it "calculates when not inverse" do
      subject.exchange_rate = 7.0
      subject.stub(account: ac_bob, account_to: ac_usd)

      #subject.inverse = false
      subject.amount_currency.should == 100.0 * 7.0
    end

    it "calculates when inverse" do
      subject.exchange_rate = 7.0
      subject.stub(account_to: ac_bob, account: ac_usd)

      subject.amount_currency.should == (1/7.0 * 100).round(4)
    end
  end

end
