# encoding: utf-8
require 'spec_helper'

describe CurrencyExchange do
  before do
    OrganisationSession.organisation = build(:organisation, currency: 'BOB')
  end

  let(:account_bob) { build :account, currency: 'BOB' }
  let(:account_usd) { build :account, currency: 'USD' }
  let(:account_eur) { build :account, currency: 'EUR' }

  it "account_to or account should be the base account in this case BOB" do
    # account: USD, account_to: EUR
    ex = CurrencyExchange.new(account: account_usd, account_to: account_eur, exchange_rate: 1.412)

    ex.should_not be_valid

    # Both accounts are EUR
    ex = CurrencyExchange.new(account: account_eur, account_to: account_eur, exchange_rate: 1.333)

    ex.should be_valid
    ex.exchange.should eq(1)
    ex.attributes.should eq({account: account_eur, account_to: account_eur, exchange_rate: 1})
  end

  it "sets to 1 when both accounts are the same currency" do
    ex = CurrencyExchange.new(account: account_eur, account_to: account_eur, exchange_rate: 1.333)

    ex.exchange_rate.should eq(1)
  end

  it "initializes with a account_ledger" do
    # account BOB, account_to USD
    ex = CurrencyExchange.new(account: account_bob, account_to: account_usd, exchange_rate: 7.012)

    ex.should_not be_inverse
    ex.should be_valid

    # account: USD, account_to: BOB
    ex = CurrencyExchange.new(account: account_usd, account_to: account_bob, exchange_rate: 7.012)
    ex.should be_inverse
    ex.should be_valid

    # account: BOB, account_to: EUR
    ex = CurrencyExchange.new(account: account_bob, account_to: account_eur, exchange_rate: 9.012)
    ex.should_not be_inverse
    ex.should be_valid

  end

  it "should return correct exchange" do
    # account: BOB, account_to: EUR
    ex = CurrencyExchange.new(account: account_bob, account_to: account_eur, exchange_rate: 9.012123)

    ex.should_not be_inverse
    ex.should be_valid

    ex.exchange.should == (9.012123 * 1).round(4)
    ex.exchange(10).should == (9.012123 * 10).round(4)

    # account: eur, account_to: BOB
    ex = CurrencyExchange.new(account: account_eur, account_to: account_bob, exchange_rate: 9.012123)

    ex.should be_inverse
    ex.should be_valid

    ex.exchange.should == (1/9.012123 * 1).round(4)
    ex.exchange(10).should == (1/9.012123 * 10).round(4)
  end
end
