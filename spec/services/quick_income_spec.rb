# encoding: utf-8
require 'spec_helper'

describe QuickIncome do
  let(:valid_attributes) {
    {
      date: Date.today, ref_number: 'I-0001', fact: true,
      bill_number: '63743'
    }
  }

  it "initializes with defaults" do
    qi = QuickIncome.new
    qi.ref_number.should eq("I-#{Date.today.year}-0001")
    qi.fact.should be_true
    qi.date.should eq(Date.today)
    #qi.currency_id.should eq()
  end

  it "initializes with other attributes" do
    date = 1.day.from_now.to_date
    qi = QuickIncome.new(ref_number: 'JE-0001', fact: false, date: date)
    qi.ref_number.should eq('JE-0001')
    qi.fact.should be_false
    qi.date.should eq(date)
  end

  context "Creation" do
    it "creates a valid income" do
      
    end
  end
end
