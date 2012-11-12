# encoding: utf-8
require 'spec_helper'

describe QuickIncome do
  before(:each) do
    UserSession.current_user = User.new {|u| u.id = 21 }
  end

  let!(:currency) { create(:currency) }
  let!(:contact) { create(:contact) }
  let!(:cash) { create(:cash, amount: 100, currency_id: currency.id) }
  let(:account) { cash.account }
  let(:initial_amount) { account.amount }

  let(:valid_attributes) {
    {
      date: Date.today, ref_number: 'I-0001', fact: true,
      bill_number: '63743', amount: '200.5',
      contact_id: contact.id, account_id: account.id
    }
  }

  it "Initializes with a correct number" do
    qi = QuickIncome.new
    qi.ref_number.should eq("I-0001")
  end

  context "Create income and check values" do
    let(:account_ledger) { subject.account_ledger }
    let(:expense) { subject.expense }
    let(:amount) { qe.amount }

    it "creates a valid income" do
      contact.should_not be_client

      qi = QuickIncome.new(valid_attributes)
      qi.create.should be_true

      qi.income.should be_persisted
      qi.account_ledger.should be_persisted
      contact.reload
      contact.should be_client
    end

    it "does not save because of invalid account" do
      qi = QuickIncome.new(valid_attributes.merge(account_id: 1000))
      qi.create.should be_false

      qi.income.errors[:currency].should_not be_blank
      qi.income.errors[:currency_id].should_not be_blank
    end

    it "should present errors if the contact is wrong" do
      qi = QuickIncome.new(valid_attributes.merge(contact_id: 1000))
      qi.create.should be_false

      qi.income.errors[:contact].should_not be_blank
    end

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
      account_ledger.should be_is_pin
      account_ledger.date.to_date.should eq(valid_attributes[:date])
      account_ledger.reference == "Corbro ingreso #{income.ref_number}"

      account_ledger.amount.should == valid_attributes[:amount].to_f
      account_ledger.transaction_id.should eq(income.id)
      account_ledger.should be_conciliation

      account_ledger.account_amount.should eq(initial_amount + income.total)
      account_ledger.creator_id.should eq(21)
      account_ledger.approver_id.should eq(21)
      account_ledger.contact_id.should eq(contact.id)
    end
  end
end
