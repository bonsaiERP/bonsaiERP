require 'spec_helper'

describe Movements::Errors do
  before(:each) do
    UserSession.user = build :user, id: 1
  end

  it "sets negative_balance" do
    i = Income.new(total: 0, balance: -1)

    Movements::Errors.new(i).set_errors
    i.stub(valid?: true)
    i.save

    i.should be_has_error
    i.error_messages.should eq({
      "balance" => ["movement.negative_balance"]
    })
  end

  it "greater balance than total" do
    e = Expense.new(total: 10, balance: 15)
    e.stub(valid?: true)
    Movements::Errors.new(e).set_errors
    e.save

    e.should be_has_error
    e.error_messages.should eq({
      "balance" => ["movement.balance_greater_than_total"]
    })
  end

  it "does not set errors" do
    i = Income.new(balance: 10, total: 10)
    Movements::Errors.new(i).set_errors

    i.should_not be_has_error
    i.error_messages.should eq({})
  end
end
