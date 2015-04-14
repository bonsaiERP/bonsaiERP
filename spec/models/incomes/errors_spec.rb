require 'spec_helper'

describe Incomes::Errors do
  subject { Income.new }

  it "initializes an income without any errors" do
    subject.should_not be_has_error
    subject.error_messages.should be_blank
  end

  it "sets error for balance" do
    subject.total = 10
    subject.balance = -1.1

    Incomes::Errors.new(subject).set_errors

    expect(subject.valid?).to eq(false)
    expect(subject.error_messages["balance"]).to eq(['movement.negative_balance'])
  end

  context "Detail errors" do
    it "present errors when details are wrong" do
      subject.income_details.build(balance: 2)
      subject.income_details.build(balance: -1)

      Incomes::Errors.new(subject).set_errors

      expect(subject.valid?).to eq(false)
      expect(subject.error_messages["income_details"]).to eq(['movement.negative_item_balance'])
    end

    it "present errors when details are wrong" do
      subject.income_details.build(balance: -2)
      subject.income_details.build(balance: -1)

      Incomes::Errors.new(subject).set_errors

      expect(subject).to be_has_error
      expect(subject.error_messages["income_details"]).to eq(['movement.negative_items_balance'])
    end
  end

  it "should set no errors if errors fixed" do
    subject.total = 10
    subject.balance = 0
    subject.has_error = true
    subject.error_messages = {a: 'A new message'}

    Incomes::Errors.new(subject).set_errors

    subject.should_not be_has_error
    subject.error_messages.should eq({})
  end
end
