# encoding: utf-8
require 'spec_helper'

describe Transference do
  let(:account){ build :cash, currency: 'BOB', id: 1 }
  let(:account_to){ build :account, currency: 'BOB', id: 2 }

  let(:valid_attributes) {
    {
      account_id: account.id, account_to_id: account_to.id, exchange_rate: 7.011,
      amount: 50, reference: 'El primer pago',
      verification: false, date: Date.today
    }
  }

  before(:each) do
    OrganisationSession.organisation = build :organisation, currency: 'BOB'
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

      it "Valid" do
        Account.stub_chain(:active, :find_by_id).with(account.id).and_return(account)
        AccountQuery.any_instance.stub_chain(:bank_cash, find_by_id: account_to )
        t = Transference.new(valid_attributes)

        t.should be_valid
      end
    end
  end
  
end
