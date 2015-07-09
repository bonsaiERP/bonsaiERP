# encoding: utf-8
require 'spec_helper'

describe AccountLedger do

  it { should belong_to(:account) }
  it { should belong_to(:account_to).class_name('Account') }
  it { should belong_to(:contact) }

  it { should belong_to(:approver).class_name('User') }
  it { should belong_to(:nuller).class_name('User') }
  it { should belong_to(:creator).class_name('User') }
  it { should belong_to(:updater).class_name('User') }

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
    it { should have_valid(:status).when( *AccountLedger::STATUSES ) }
    it { should_not have_valid(:status).when( 'other', 'null' ) }

    it { should have_valid(:amount).when(0.25, -0.25) }
    it { should_not have_valid(:amount).when('', nil) }
    it { should have_valid(:exchange_rate).when(0.25, 10) }
    it { should_not have_valid(:exchange_rate).when(0.0, -1.2, '', nil) }

    it "does not allow the same account" do
      subject.account_to_id = account.id

      expect(subject.valid?).to eq(false)
      expect(subject.errors[:account_to_id].present?).to eq(true)
    end
  end

  it "#status methods" do
    al = AccountLedger.new
    AccountLedger::STATUSES.each do |st|
      al.should respond_to(:"is_#{st}?")
      al.status = st
      al.should send(:"be_is_#{st}")
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
    a = AccountLedger.new(valid_attributes.merge(contact_id: 2))
    a.currency.should be_nil
    a.stub(account: account, account_to: account2)

    a.should be_valid
    a.currency.should eq('BOB')
  end

  context "save_ledger" do
    it "Creates a new instance of Conciliation" do
      ledger = build :account_ledger
      ledger.should be_is_approved

      # Check ConciliateAccount#conciliate
      ConciliateAccount.method_defined?(:conciliate).should eq(true)
      #stub
      ConciliateAccount.any_instance.should_receive(:conciliate).and_return( true)
      ledger.should_not_receive(:save)


      ledger.save_ledger.should eq(true)
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

  it "#can_conciliate_or_null?" do
    al = AccountLedger.new
    al.should be_can_conciliate_or_null

    al.nuller_id = 1
    al.should_not be_can_conciliate_or_null

    al.nuller_id = nil
    al.approver_id = 1
    al.should_not be_can_conciliate_or_null

    al.nuller_id = 1
    al.approver_id = 1
    al.should_not be_can_conciliate_or_null
  end

  before(:each) do
    UserSession.user = build :user, id: 10
  end

  context 'Code' do
    let(:ac_bob) { build :cash, currency: 'BOB' }
    let(:ac_usd) { build :cash, currency: 'USD' }

    it "code" do
      AccountLedger.any_instance.stub(account: ac_bob, account_to: ac_usd, contact_id: 2)
      y = Date.today.year.to_s[2..3]

      al = AccountLedger.create(valid_attributes)
      al.should be_persisted
      al.name.should eq("T-#{y}-0001")

      al = AccountLedger.create(valid_attributes)
      al.should be_persisted
      al.name.should eq("T-#{y}-0002")

      al.update_attributes(reference: 'Changed ref')

      AccountLedger.order('name').pluck(:name).should eq(["T-#{y}-0001", "T-#{y}-0002"])
    end
  end

  it "validation for trans" do
    al = AccountLedger.new(valid_attributes.merge(
      reference: 'Old reference', contact_id: nil,
      operation: 'trans'))
    al.stub(account: account, account_to: account2)

    al.should be_valid

    al.operation = 'payin'

    al.should_not be_valid
  end
end
