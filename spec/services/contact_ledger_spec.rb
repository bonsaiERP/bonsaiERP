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

  context "Validations" do
    subject { ContactLedger.new valid_attributes }
    it { should have_valid(:amount).when(0.5) }
    it { should_not have_valid(:amount).when(-0.5) }

    it "set correct errormessages" do
      subject.contact_id = 1000
      subject.currency_id = 1000

      subject.should_not be_valid
      [:contact_id, :currency_id].each do |met|
        subject.errors[met].should_not be_empty
      end
    end

    it "should not allow invalid currency and account" do
      cur2 = create(:currency, name: 'Dollar', code: 'USD')
      cl = ContactLedger.new(valid_attributes.merge(currency_id: cur2.id))
      cl.should_not be_valid
      cl.errors[:currency_id].should_not be_empty
    end
  end
end
