# encoding: utf-8
require 'spec_helper'

describe QuickTransaction do
  before(:each) do
    UserSession.user = build :user, id: 21
  end

  let!(:contact) { create(:contact) }
  let!(:cash) { create(:cash, amount: 100, currency: 'BOB') }
  let(:account) { cash.account }
  let(:initial_amount) { account.amount }

  let(:valid_attributes) {
    {
      date: Date.today, ref_number: 'I-0001', fact: true,
      bill_number: '63743', amount: '200.5',
      contact_id: contact.id, account_id: account.id
    }
  }

  it "initializes with defaults" do
    qi = QuickTransaction.new
    qi.fact.should be_true
    qi.date.should eq(Date.today)
  end

  it "initializes with other attributes" do
    date = 1.day.from_now.to_date
    qi = QuickTransaction.new(ref_number: 'JE-0001', fact: false, date: date)
    qi.ref_number.should eq('JE-0001')
    qi.fact.should be_false
    qi.date.should eq(date)
  end

end
