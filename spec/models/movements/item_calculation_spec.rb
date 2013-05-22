require 'spec_helper'

describe Movements::ItemCalculation do
  subject do
    i = Income.new
    i.income_details.build(price: 10, quantity: 10, balance: 10, original_price: 10)
    i.income_details.build(price: 20, quantity: 5, balance: 5, original_price: 19)
    i
  end


  it "#subtotal" do
    m = Movements::ItemCalculation.new(subject)
    m.subtotal.should == 200.0
  end

  it "#original_price" do
    m = Movements::ItemCalculation.new(subject)
    m.original_total.should == 200.0 - 5
  end

  it "inventory_balance" do
    subject.income_details[0].balance = 5
    m = Movements::ItemCalculation.new(subject)

    m.inventory_balance.should == 150.0
  end

  it "#items_left" do
    subject.income_details[0].balance = 5
    m = Movements::ItemCalculation.new(subject)

    m.items_left.should == 10
  end
end
