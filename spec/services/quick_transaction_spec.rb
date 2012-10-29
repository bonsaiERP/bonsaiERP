# encoding: utf-8
require 'spec_helper'

describe QuickTransaction do
  before(:each) do
    UserSession.current_user = User.new {|u| u.id = 21 }
  end

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
    qi = QuickTransaction.new
    qi.ref_number.should eq("I-#{Date.today.year}-0001")
    qi.fact.should be_true
    qi.date.should eq(Date.today)
    #qi.currency_id.should eq()
  end

  it "initializes with other attributes" do
    date = 1.day.from_now.to_date
    qi = QuickTransaction.new(ref_number: 'JE-0001', fact: false, date: date)
    qi.ref_number.should eq('JE-0001')
    qi.fact.should be_false
    qi.date.should eq(date)
  end

  context "Creation" do
    it "creates a valid income" do
      qi = QuickTransaction.new(valid_attributes)
      qi.create_in.should be_true

      qi.income.should be_persisted
      qi.account_ledger.should be_persisted
    end

    it "does not saave because of invalid account" do
      qi = QuickTransaction.new(valid_attributes.merge(account_id: 1000))
      qi.create_in.should be_false

      qi.account_ledger.errors[:account].should_not be_blank
      qi.account_ledger.errors[:currency].should_not be_blank
    end

    context "Create QuickOffer and check values" do
      subject do
        qi = QuickTransaction.new(valid_attributes)
        qi.create_in
        qi
      end


      let(:account_ledger) { subject.account_ledger }
      let(:income) { subject.income }

      it "account_ledger attribtes are set" do
        account_ledger.contact_id.should eq(contact.id)
        account_ledger.should be_persisted
        account_ledger.should be_is_pin

        account_ledger.amount.should == valid_attributes[:amount].to_f
        account_ledger.transaction_id.should eq(income.id)
        account_ledger.should be_conciliation

        account_ledger.account.amount.should eq(income.total)
        account_ledger.creator_id.should eq(21)
        account_ledger.approver_id.should eq(21)
        account_ledger.contact_id.should eq(contact.id)
      end
    end
  end
end
