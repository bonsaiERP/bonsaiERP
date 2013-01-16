# encoding: utf-8
require 'spec_helper'

describe QuickTransaction do
  let(:valid_attributes) {
    {
      date: Date.today, ref_number: 'I-0001',
      bill_number: '63743', amount: '200.5',
      contact_id: 1, account_to_id: 1
    }
  }

  context 'Validations' do
    it "shoulda validations" do
      [:ref_number, :account_to_id, :contact_id, :date].each do |meth|
        should_not have_valid(meth).when(nil, '')
      end
    end

    it { should have_valid(:amount).when(0.1, 2, 100.23) }
    it { should_not have_valid(:amount).when(0, nil, -1) }

    it "has validations for account and contact" do
      QuickTransaction.validators_on(:contact).should_not be_blank
      QuickTransaction.validators_on(:contact).first.should be_a(ActiveModel::Validations::PresenceValidator)

      QuickTransaction.validators_on(:account_to).should_not be_blank
      QuickTransaction.validators_on(:account_to).first.should be_a(ActiveModel::Validations::PresenceValidator)
    end
  end

  it "initializes with defaults" do
    qi = QuickTransaction.new(valid_attributes.merge(date: nil))
    qi.date.should eq(Date.today)
    qi.amount.should == 200.5
  end

  it "initializes with other attributes" do
    date = 1.day.from_now.to_date
    qi = QuickTransaction.new(ref_number: 'JE-0001', date: date)
    qi.ref_number.should eq('JE-0001')
    qi.date.should eq(date)
  end

end
