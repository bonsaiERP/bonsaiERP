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
