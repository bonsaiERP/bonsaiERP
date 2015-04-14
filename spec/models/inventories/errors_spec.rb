require 'spec_helper'

describe Inventories::Errors do
  class StockTest < OpenStruct; end


  def get_stocks
    [
      StockTest.new(quantity: 1, item_id: 1),
      StockTest.new(quantity: -1, item_id: 2),
      StockTest.new(quantity: -2, item_id: 3)
    ]
  end

  let(:inventory) {
    Inventory.new(inventory_details_attributes: [
      {item_id: 1, quantity: 2},
      {item_id: 2, quantity: 2},
      {item_id: 3, quantity: 2}
    ])
  }

  it "#set_errors" do
    Inventories::Errors.new(inventory, get_stocks).set_errors

    expect(inventory.valid?).to eq(false)
    inventory.error_messages.should eq({
      "quantity" => ['inventory.negative_stock'],
      "item_ids" => [2, 3]
    })
  end
end
