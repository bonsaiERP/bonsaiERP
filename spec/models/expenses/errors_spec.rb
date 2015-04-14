require 'spec_helper'

describe Expenses::Errors do
  subject { Expense.new }

  it "initializes an expense without any errors" do
    subject.should_not be_has_error
    subject.error_messages.should be_blank
  end

  it "sets error for balance" do
    subject.total = 10
    subject.balance = -1.1

    Expenses::Errors.new(subject).set_errors

    expect(subject.valid?).to eq(false)
    expect(subject.error_messages["balance"]).to eq(['movement.negative_balance'])
  end

  context "Detail errors" do
    it "present errors when details are wrong" do
      subject.expense_details.build(balance: 2)
      subject.expense_details.build(balance: -1)

      Expenses::Errors.new(subject).set_errors

      expect(subject.valid?).to eq(false)
      expect(subject.error_messages["expense_details"]).to eq(['movement.negative_item_balance'])
    end

    it "present errors when details are wrong" do
      subject.expense_details.build(balance: -2)
      subject.expense_details.build(balance: -1)

      Expenses::Errors.new(subject).set_errors

      expect(subject.valid?).to eq(false)
      expect(subject.error_messages["expense_details"]).to eq(['movement.negative_items_balance'])
    end
  end

  it "should set no errors if errors fixed" do
    subject.total = 10
    subject.balance = 0
    subject.has_error = true
    subject.error_messages = {a: 'A new message'}

    Expenses::Errors.new(subject).set_errors

    subject.should_not be_has_error
    subject.error_messages.should eq({})
  end
end
