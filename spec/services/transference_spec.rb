# encoding: utf-8
require 'spec_helper'

describe Transference do
  let(:account){ build :cash, currency: 'BOB', id: 1 }
  let(:account_to){ build :account, currency: 'BOB', id: 2 }
  let(:account_usd) { build :cash, currency: 'USD', id: 3 }

  let(:valid_attributes) {
    {
      account_id: account.id, account_to_id: account_to.id, exchange_rate: 7.011,
      amount: 50, reference: 'El primer pago',
      verification: false, date: Date.today, total: 50
    }
  }

  before(:each) do
    OrganisationSession.organisation = build :organisation, currency: 'BOB'
  end

  it "#account once" do
    Account.should_receive(:active).once.and_return(double(find_by_id: account) )

    t = Transference.new

    t.account
    t.account
    t.account
  end

  it "#account_to once" do
    AccountQuery.any_instance.should_receive(:bank_cash).once.and_return(double(find_by_id: account_to) )

    t = Transference.new

    t.account_to
    t.account_to
    t.account_to
  end

  context 'Validations' do
    it { should validate_presence_of(:account_id) }
    it { should validate_presence_of(:account_to_id) }
    it { should validate_presence_of(:reference) }
    it { should validate_presence_of(:date) }

    it { should have_valid(:date).when('2012-12-12') }
    it { should_not have_valid(:date).when('anything') }
    it { should_not have_valid(:date).when('') }
    it { should_not have_valid(:date).when('2012-13-13') }

    it { should_not have_valid(:amount).when(-1) }

    it "uses the CurrencyExchange validation to validate currency accounts" do
      CurrencyExchange.any_instance.should_receive(:valid?).at_least(1).times.and_return(false)

      t = Transference.new(valid_attributes)

      t.should_not be_valid
      t.errors_on(:base).should eq([I18n.t('errors.messages.payment.valid_accounts_currency', currency: OrganisationSession.currency)])
    end

    context "account_to" do
      before(:each) do
        #Account.stub_chain(:active, :find_by_id).with(1).and_return(transaction)
      end

      it "Not valid" do
        ob = Object.new
        ob.stub(:find_by_id).with(2).and_return(nil)
        AccountQuery.any_instance.stub(bank_cash: ob)
        t = Transference.new(valid_attributes)

        t.should_not be_valid
        t.errors_on(:account_to).should_not be_empty
      end

      it "check conciliation" do
        t = Transference.new(verification: true)
        t.stub(account: account, account_to: account_to)

        t.should be_verification
        t.send(:get_status).should eq('approved')

        # bank on any
        bank = build :bank, currency: 'BOB'
        t = Transference.new(verification: true)
        t.stub(account: account, account_to: bank)

        t.should be_verification
        t.send(:get_status).should eq('pendent')

        #bank on account
        t = Transference.new(verification: true)
        t.stub(account: bank, account_to: account)

        t.should be_verification
        t.send(:get_status).should eq('pendent')
      end

      it "Valid" do
        Account.stub_chain(:active, :find_by_id).with(account.id).and_return(account)
        AccountQuery.any_instance.stub_chain(:bank_cash, find_by_id: account_to )
        t = Transference.new(valid_attributes)

        t.should be_valid
      end
    end
  end

  context "Save" do
    before(:each) do
      AccountLedger.any_instance.stub(save: true)
      ConciliateAccount.any_instance.stub(conciliate!: true)
    end

    it "saves" do
      t = Transference.new(valid_attributes)
      t.stub(account: account, account_to: account_to)
      ConciliateAccount.any_instance.should_receive(:conciliate!).and_return(true)

      t.transfer.should be_true

      # Ledger
      t.ledger.should be_is_trans
      t.ledger.currency.should eq('BOB')
      t.account_id.should eq(1)
      t.account_to_id.should eq(2)
      t.ledger.should_not be_inverse
      t.ledger.should be_is_approved
      t.ledger.amount.should == 50.0
    end

    it "to other currency account" do
      account_to2 = build(:bank, id: 4, currency: 'USD')

      t = Transference.new(valid_attributes.merge(account_to_id: 3, exchange_rate: 7.0, verification: true, total: 7.0 * 10, amount: 10))
      t.stub(account: account, account_to: account_to2)

      t.transfer.should be_true

      # Ledger
      t.ledger.currency.should eq('USD')
      t.account_id.should eq(1)
      t.account_to_id.should eq(3)
      t.ledger.should_not be_inverse
      t.ledger.exchange_rate.should == 7.0
      t.ledger.amount.should == 10

      t.ledger.should_not be_is_approved
    end

    it "inverse" do
      t = Transference.new(valid_attributes.merge(account_id: account_usd.id,
          account_to_id: account.id, exchange_rate: 7.0, verification: true, total: 10, amount: 70))
      t.stub(account: account_usd, account_to: account)

      t.transfer.should be_true

      t.ledger.should be_inverse
      t.ledger.amount.should == 70
      t.exchange_rate.should == 7.0
    end

  end

end
