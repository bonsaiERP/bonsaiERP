# encoding: utf-8
require 'spec_helper'

describe LedgerExchange do
  let(:ledger) { build :account_ledger, amount: 100, exchange_rate: 1, inverse: false, currency: 'BOB' }

  it "initializes with a account_ledger" do
    OpenStruct.new()
  end
end
