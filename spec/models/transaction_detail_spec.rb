require 'spec_helper'

describe TransactionDetail do
  it{ should validate_presence_of(:item_id) }
  it{ should have_valid(:quantity).when(0.1, 1)}
  it{ should_not have_valid(:quantity).when(0)}

  it "calculates total" do
    td = TransactionDetail.new(quantity: 2, price: 4)
    td.total.should eq(8)
  end
end
