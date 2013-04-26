# encoding: utf-8
require 'spec_helper'

describe QuickIncome do
  let(:user) { build :user, id: 21 }

  before(:each) do
    UserSession.user = build :user, id: 21
  end

  let(:contact) { build :contact, id: 1 }
  let(:account_to) { build :cash, amount: 100, currency: 'BOB', id: 1 }
  let(:initial_amount) { account.amount }

  let(:valid_attributes) {
    {
      date: Date.today, ref_number: 'I-0001',
      bill_number: '63743', amount: '200.5',
      contact_id: contact.id, account_to_id: account_to.id
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
      Income.any_instance.stub(save: true, id: 11)

      Account.stub(find_by_id: account_to)
      Contact.stub(find_by_id: contact)
      # save_ledger conciliates if conciliation = true
      AccountLedger.any_instance.stub(save_ledger: true)
    end

    it "creates a valid income" do
      qi = QuickIncome.new(valid_attributes)
      qi.create.should be_true

      # income
      income = qi.income
      income.should be_is_a(Income)
      income.currency.should eq('BOB')
      income.ref_number.should =~ /I-\d{2}-\d{4}/
      income.total.should == 200.5
      income.balance.should == 0.0
      income.gross_total.should == 200.5
      income.total.should == 200.5
      income.original_total.should == 200.5
      income.date.should eq(valid_attributes.fetch(:date) )
      income.due_date.should eq(income.date)

      income.creator_id.should eq(21)
      income.approver_id.should eq(21)
      income.approver_datetime.should be_is_a(Time)

      # account_ledger
      ledger = qi.account_ledger
      ledger.account_id.should eq(11)
      ledger.account_to_id.should eq(account_to.id)
      ledger.currency.should eq("BOB")

      ledger.amount.should == 200.5
      ledger.exchange_rate.should == 1
      ledger.should_not be_inverse

      ledger.creator_id.should eq(21)
      ledger.approver_id.should eq(21)

      ledger.reference.should eq("Cobro ingreso #{income.ref_number}")
      ledger.should be_is_payin
      
      ledger.should be_is_approved
      ledger.date.should be_a(Time)

      ledger.creator_id.should eq(21)
      ledger.approver_id.should eq(21)
    end

    it "Can accept different values for conciliation when Bank account" do
      Account.stub(find_by_id: build(:bank, id: 3, currency: 'USD'))

      qi = QuickIncome.new(valid_attributes.merge(account_to_id: 3, verification: true))
      qi.create.should be_true

      ledger = qi.account_ledger

      ledger.should be_is_approved

      # Other case
      qi = QuickIncome.new(valid_attributes.merge(account_to_id: 3, verification: false))
      qi.create.should be_true

      ledger = qi.account_ledger

      ledger.should be_is_approved
    end

    it "Assigns the currency of the account" do
      Account.stub(find_by_id: build(:bank, id: 3, currency: 'USD'))
      
      qi = QuickIncome.new(valid_attributes.merge(account_to_id: 3) )

      qi.create.should be_true

      qi.income.currency.should eq('USD')
    end
  end
end
