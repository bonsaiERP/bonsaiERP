# encoding: utf-8
require 'spec_helper'

describe ContactLedger do
  let!(:currency) { create(:currency) }
  let!(:contact) { create(:contact) }
  let!(:cash) { create(:cash, amount: 0, currency_id: currency.id) }
  let(:account) { cash.account }

  let(:valid_attributes) {
    {
      date: Date.today, ref_number: 'I-0001', fact: true,
      bill_number: '63743', amount: '200.5', currency_id: currency.id,
      contact_id: contact.id, account_id: account.id
    }
  }

  it "should initialize" do
    
  end
end
