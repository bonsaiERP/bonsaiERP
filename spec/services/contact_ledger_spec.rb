# encoding: utf-8
require 'spec_helper'

describe ContactLedger do
  let!(:currency) { create(:currency) }
  let!(:contact) { create(:contact) }
  let!(:cash) { create(:cash, amount: 0, currency_id: currency.id) }
  let(:account) { cash.account }
  let(:amount) { 200.5 }

  let(:valid_attributes) {
    {
      date: Date.today, ref_number: 'I-0001',
      bill_number: '63743', amount: amount.to_s, 
      reference: 'My buddy payed me', contact_id: contact.id, 
      account_id: account.id
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
      #puts al.attributes

      al.account_amount.should eq(initial_amount + amount)
      al.account_balance.should eq(al.account_amount)

      al.to_amount.should eq(-amount)
      al.to_balance.should eq(-amount)
    end
  end

  context "Validations" do
    #subject { ContactLedger.new valid_attributes }
    #it { should have_valid(:amount).when(0.5) }
    #it { should_not have_valid(:amount).when(-0.5) }

    #it "set correct errormessages" do
    #  subject.contact_id = 1000
    #  subject.currency_id = 1000

    #  subject.should_not be_valid
    #  [:contact_id, :currency_id].each do |met|
    #    subject.errors[met].should_not be_empty
    #  end
    #end

    #it "should not allow invalid currency and account" do
    #  cur2 = create(:currency, name: 'Dollar', code: 'USD')
    #  cl = ContactLedger.new(valid_attributes.merge(currency_id: cur2.id))
    #  cl.should_not be_valid
    #  cl.errors[:currency_id].should_not be_empty
    #end
  end
end
