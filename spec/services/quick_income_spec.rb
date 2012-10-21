# encoding: utf-8
require 'spec_helper'

describe QuickIncome do
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

  it "initializes with defaults" do
    qi = QuickIncome.new
    qi.ref_number.should eq("I-#{Date.today.year}-0001")
    qi.fact.should be_true
    qi.date.should eq(Date.today)
    #qi.currency_id.should eq()
  end

  it "initializes with other attributes" do
    date = 1.day.from_now.to_date
    qi = QuickIncome.new(ref_number: 'JE-0001', fact: false, date: date)
    qi.ref_number.should eq('JE-0001')
    qi.fact.should be_false
    qi.date.should eq(date)
  end

  context "Creation" do
    it "creates a valid income" do
      qi = QuickIncome.new(valid_attributes)
      qi.create.should be_true

      qi.income.should be_persisted
      qi.account_ledger.should be_persisted
    end

    context "Create QuickOffer and check values" do
      subject do
        qi = QuickIncome.new(valid_attributes)
        qi.create
        qi
      end


      let(:account_ledger) { subject.account_ledger }
      let(:income) { subject.income }

      it "account_ledger attribtes are set" do
        account_ledger.contact_id.should eq(contact.id)
        account_ledger.should be_persisted
        account_ledger.should be_in

        account_ledger.amount.should == valid_attributes[:amount].to_f
        account_ledger.transaction_id.should eq(income.id)
        account_ledger.should be_make_conciliation
      end
    end
  end
end
