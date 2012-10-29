# encoding: utf-8
require 'spec_helper'

describe ContactLedger do
  before(:each) do
    UserSession.current_user = build(:user, id: 10)
  end

  let!(:currency) { create(:currency) }
  let!(:contact) { create(:contact) }
  let!(:cash) { create(:cash, amount: 100, currency_id: currency.id) }
  let(:account) { cash.account }
  let(:amount) { 200.5 }

  let(:valid_attributes) {
    {
      date: Date.today, reference: 'Contact 0001',
      amount: amount.to_s, reference: 'My buddy payed me', 
      contact_id: contact.id, account_id: account.id
    }
  }

  it "test account ledger" do
    cl = ContactLedger.new(valid_attributes)

    cl.account_ledger.amount.should eq(valid_attributes[:amount].to_f)
    cl.account_ledger.exchange_rate.should eq(1)
  end

  context "Create in" do
    let(:initial_amount) { account.amount }
    it "creates an in" do
      cl = ContactLedger.new valid_attributes

      cl.create_in.should be_true
      #puts cl.account_ledger.errors.messages
      al = cl.account_ledger
      al.should be_persisted
      al.should be_is_cin
      al.contact_id.should eq(contact.id)

      al.amount.should eq(amount)
      al.currency_id.should eq(account.currency_id)

      al.account_amount.should eq(initial_amount + amount)
      al.account_balance.should eq(al.account_amount)

      al.to_amount.should eq(-amount)
      al.to_balance.should eq(-amount)

      al.contact.account_cur(currency.id).should be_persisted
      al.creator_id.should eq(UserSession.user_id)
      al.approver_id.should eq(UserSession.user_id)
    end


    it "creates an in without conciliation" do
      cl = ContactLedger.new valid_attributes

      cl.create_in(false).should be_true
      #puts cl.account_ledger.errors.messages
      al = cl.account_ledger
      al.should be_persisted
      al.should be_is_cin
      al.contact_id.should eq(contact.id)

      al.amount.should eq(amount)
      al.currency_id.should eq(account.currency_id)

      al.account_amount.should eq(initial_amount)
      al.account_balance.should be_nil

      al.to_amount.should eq(0)
      al.to_balance.should be_nil

      al.contact.account_cur(currency.id).should be_persisted
      al.creator_id.should eq(UserSession.user_id)
      al.approver_id.should be_nil

      # Conciliation
      UserSession.current_user = build(:user, id: 14)
      al.conciliate_account.should be_true
      al.approver_id.should eq(14)

      al.account_amount.should eq(initial_amount + amount)
      al.account_balance.should eq(initial_amount + amount)

      al.to_amount.should eq(-amount)
      al.to_balance.should eq(-amount)
    end
  end

  context "Create out" do
    let(:initial_amount) { account.amount }

    it "creates an out" do
      cl = ContactLedger.new valid_attributes

      cl.create_out.should be_true

      al = cl.account_ledger
      al.should be_persisted
      al.should be_is_cout
      al.contact_id.should eq(contact.id)

      al.amount.should eq(-amount)
      al.currency_id.should eq(account.currency_id)

      al.account_amount.should eq(initial_amount - amount)
      al.account_balance.should eq(initial_amount - amount)

      al.to_amount.should eq(amount)
      al.to_balance.should eq(amount)
    end

    it "creates an out without conciliation" do
      cl = ContactLedger.new valid_attributes

      cl.create_out(false).should be_true

      al = cl.account_ledger
      al.should be_persisted
      al.should be_is_cout
      al.contact_id.should eq(contact.id)

      al.amount.should eq(-amount)
      al.currency_id.should eq(account.currency_id)

      al.account_amount.should eq(initial_amount)
      al.account_balance.should be_nil

      al.to_amount.should eq(0)
      al.to_balance.should be_nil
      al.creator_id.should eq(UserSession.user_id)
      al.approver_id.should be_nil

      # Conciliation
      UserSession.current_user = build(:user, id: 12)
      al.conciliate_account.should be_true
      al.approver_id.should eq(12)

      al.account_amount.should eq(initial_amount - amount)
      al.account_balance.should eq(initial_amount - amount)

      al.to_amount.should eq(amount)
      al.to_balance.should eq(amount)
    end
  end
end
