# encoding: utf-8
require 'spec_helper'

describe QuickIncome do
  let(:user) { build :user, id: 21 }

  before(:each) do
    UserSession.user = build :user, id: 21
    #UserChange.any_instance.stub(save: true, user: user)
  end

  let(:contact) { build :contact, id: 1 }
  let(:account) { build :cash, amount: 100, currency: 'BOB', id: 1 }
  let(:initial_amount) { account.amount }

  let(:valid_attributes) {
    {
      date: Date.today, ref_number: 'I-0001',
      bill_number: '63743', amount: '200.5',
      contact_id: contact.id, account_to_id: account.id
    }
  }


  context "Create income and check values" do
    before(:each) do
      Income.any_instance.stub(save: true)
      AccountLedger.any_instance.stub(save: true)

      Account.stub(find: account)
    end

    it "creates a valid income" do
      qi = QuickIncome.new(valid_attributes)
      qi.create.should be_true

      income = qi.income
      income.total.should == 200.5
      income.balance.should == 0.0
      income.gross_total.should == 200.5
      income.total.should == 200.5
      income.original_total.should == 200.5

      income.creator_id.should eq(21)
      income.approver_id.should eq(21)
    end

    it "does not save because of invalid account" do
      qi = QuickIncome.new(valid_attributes.merge(account_id: 1000))
      qi.create.should be_false

      qi.income.errors[:currency].should_not be_blank
      qi.income.errors[:currency].should_not be_blank
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

    it "sets correctly income attributes" do
      amount = valid_attributes[:amount].to_f

      income.balance.should eq(0)
      income.total.should eq(amount)
      income.gross_total.should eq(amount)
      income.original_total.should eq(amount)
      income.should be_is_paid
      income.date.should_not be_blank
      income.payment_date.should eq(income.date)

      income.user_changes.should have(2).items
      income.user_changes.map(&:name).sort.should eq(['approver', 'creator'])
      income.user_changes.map(&:user_id).should eq([21, 21])
    end

    it "account_ledger attribtes are set" do
      account_ledger.contact_id.should eq(contact.id)
      account_ledger.should be_persisted
      account_ledger.should be_is_payin
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
