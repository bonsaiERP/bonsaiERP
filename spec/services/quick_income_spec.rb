# encoding: utf-8
require 'spec_helper'

describe QuickIncome do
  let(:user) { build :user, id: 21 }

  before(:each) do
    UserSession.user = build :user, id: 21
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

  it "should present errors if the contact is wrong" do
    qi = QuickIncome.new(valid_attributes.merge(contact_id: 1000, account_to_id: 1200))
    qi.create.should be_false

    qi.errors_on(:contact).should_not be_blank
    qi.errors_on(:account_to).should_not be_blank
  end

  context "Create income and check values" do
    before(:each) do
      Income.any_instance.stub(save: true)

      Account.stub(find_by_id: account)
      Contact.stub(find_by_id: contact)
      ConciliateAccount.any_instance.stub(conciliate: true)
    end

    it "creates a valid income" do
      Income.any_instance.stub(id: 11)

      qi = QuickIncome.new(valid_attributes)
      qi.create.should be_true

      # income
      income = qi.income
      income.ref_number.should eq("I-0001")
      income.total.should == 200.5
      income.balance.should == 0.0
      income.gross_total.should == 200.5
      income.total.should == 200.5
      income.original_total.should == 200.5

      income.creator_id.should eq(21)
      # approver should be set by ConciliateAccount
      #income.approver_id.should eq(21)

      # account_ledger
      ledger = qi.account_ledger
      ledger.account_id.should eq(11)
      ledger.account_to_id.should eq(account.id)
      ledger.currency.should eq("BOB")

      ledger.amount.should == 200.5
      ledger.exchange_rate.should == 1
      ledger.should_not be_inverse

      ledger.creator_id.should eq(21)
      ledger.approver_id.should eq(21)

      ledger.reference.should eq("Ingreso rápido #{income.ref_number}")
      ledger.should be_is_payin
      ledger.should be_conciliation
      ledger.date.should be_a(Time)

      ledger.creator_id.should eq(21)
      ledger.approver_id.should eq(21)
    end
  end
end
