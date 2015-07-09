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
    Accounts::Query.any_instance.should_receive(:money).once.and_return(double(find_by_id: account_to) )

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
      t.errors[:base].should eq([I18n.t('errors.messages.payment.valid_accounts_currency', currency: OrganisationSession.currency)])
    end

    context "account_to" do

      it "Not valid" do
        ob = Object.new
        ob.stub(:find_by_id).with(2).and_return(nil)
        Accounts::Query.any_instance.stub(bank_cash: ob)
        t = Transference.new(valid_attributes)

        t.should_not be_valid
        t.errors[:account_to].should_not be_empty
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
        Accounts::Query.any_instance.stub_chain(:money, find_by_id: account_to )
        t = Transference.new(valid_attributes)

        t.should be_valid
      end
    end
  end

  context "Save" do
    before(:each) do
      #AccountLedger.any_instance.stub(save: true)
      #ConciliateAccount.any_instance.stub(conciliate!: true)
      UserSession.user = build :user, id: 10
    end

    let(:attributes) {
      {
        exchange_rate: 1,
        amount: 50, reference: 'El primer pago',
        verification: false, date: Date.today, total: 50
      }
    }

    it "saves" do
      ac1 = create :cash, currency: 'BOB', amount: 100
      ac2 = create :bank, currency: 'BOB', amount: 0

      attrs = attributes.merge(account_id: ac1.id, account_to_id: ac2.id,
                       exchange_rate: 7.1, amount: 10)

      t = Transference.new(attrs)

      #ConciliateAccount.any_instance.should_receive(:conciliate!).and_return(true)
      t.transfer.should eq(true)

      # Ledger
      t.ledger.should be_is_trans
      t.ledger.currency.should eq('BOB')
      t.account_id.should eq(ac1.id)
      t.account_to_id.should eq(ac2.id)
      t.ledger.should_not be_inverse
      t.ledger.should be_is_approved
      t.ledger.amount.should == 10.0

      Account.find(ac1.id).amount.should == 90
      Account.find(ac2.id).amount.should == 10
    end

    it "to other currency account" do
      ac1 = create :cash, currency: 'BOB', amount: 100
      ac2 = create :bank, currency: 'USD', amount: 0

      attrs = attributes.merge(account_id: ac1.id, account_to_id: ac2.id,
                       exchange_rate: 7.0, amount: 14)

      t = Transference.new(attrs)

      t.transfer.should eq(true)

      # Ledger
      t.ledger.currency.should eq('USD')
      t.account_id.should eq(ac1.id)
      t.account_to_id.should eq(ac2.id)
      t.ledger.should_not be_inverse
      t.ledger.exchange_rate.should == 7.0
      t.ledger.amount.should == 2

      Account.find(ac1.id).amount.should == 100 - 14
      Account.find(ac2.id).amount.should == 2
    end

    it "inverse" do
      ac1 = create :cash, currency: 'USD', amount: 100
      ac2 = create :bank, currency: 'BOB', amount: 0

      attrs = attributes.merge(account_id: ac1.id, account_to_id: ac2.id,
                       exchange_rate: 7.0, amount: 2)

      t = Transference.new(attrs)

      t.transfer.should eq(true)

      t.ledger.should be_inverse
      t.ledger.amount.should == 14
      t.exchange_rate.should == 7.0

      Account.find(ac1.id).amount.should == 100 - 2
      Account.find(ac2.id).amount.should == 14
    end

    it "#verification" do
      ac1 = create :cash, currency: 'USD', amount: 100
      ac2 = create :bank, currency: 'BOB', amount: 0

      attrs = attributes.merge(account_id: ac1.id, account_to_id: ac2.id,
                       exchange_rate: 7.0, amount: 2, verification: true)

      t = Transference.new(attrs)

      t.transfer.should eq(true)

      t.ledger.should be_inverse
      t.ledger.amount.should == 14
      t.exchange_rate.should == 7.0

      Account.find(ac1.id).amount.should == 100
      Account.find(ac2.id).amount.should == 0
    end

  end

end
