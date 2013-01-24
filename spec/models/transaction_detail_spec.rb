require 'spec_helper'

describe TransactionDetail do
  it{ should validate_presence_of(:item_id) }
  it{ should have_valid(:quantity).when(0.1, 1)}
  it{ should_not have_valid(:quantity).when(0)}

  it "calculates total and return data_has" do
    td = TransactionDetail.new(quantity: 2, price: 4, original_price: 4)
    td.total.should eq(8)
    td.subtotal.should eq(8)

    td.data_hash.should eq({
      original_price: td.original_price, 
      price: td.price, 
      quantity: td.quantity, 
      subtotal: td.subtotal
    })
  end

  it "indicates change of price" do
    td = TransactionDetail.new(quantity: 2, price: 4, original_price: 1.9)
    td.should be_changed_price
  end
end
