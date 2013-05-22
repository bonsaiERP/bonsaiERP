# encoding: utf-8
require 'spec_helper'

describe Inventories::In do
  let(:store) { build :store, id: 1 }
  let(:valid_attributes) {
    {store_id: 1, date: Date.today, description: 'Test inventory in',
     inventory_details_attributes: [
       {item_id: 1, quantity: 2},
       {item_id: 2, quantity: 2}
    ]
    }
  }
  let(:item) { build :item }
  let(:store) { build :store }
  let(:user) { build :user, id: 10 }

  it "#initialize" do
    invin = Inventories::In.new

    invin.inventory.should be_is_in
  end

  before(:each) do
    UserSession.user = user
    Store.stub_chain(:active, where: [store])
  end

  it "creates" do
    InventoryDetail.any_instance.stub(item: item)
    Inventory.any_instance.stub(store: store)
    Stock.any_instance.stub(item: item, store: store)

    invin = Inventories::In.new(valid_attributes)
    invin.inventory_details.should have(2).items

    invin.create.should be_true
    io = Inventory.find(invin.inventory.id)
    io.should be_is_a(Inventory)
    io.should be_is_in
    io.creator_id.should eq(user.id)
    io.ref_number.should =~ /\AI-\d{2}-\d{4}\z/

    io.inventory_details.should have(2).items
    io.inventory_details.map(&:quantity).should eq([2, 2])
    io.inventory_details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([2, 2])

    # More items
    attrs = valid_attributes.merge(inventory_details_attributes:
      [{item_id: 2, quantity: 2, store_id: 1},
       {item_id: 12, quantity: 5, store_id: 1}
      ]
    )
    invin = Inventories::In.new(attrs)
    invin.create.should be_true
    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(3).items

    stocks.find {|v| v.item_id === 2}.quantity.should == 4
    stocks.find {|v| v.item_id === 12}.quantity.should == 5
    stocks.find {|v| v.item_id === 1}.quantity.should == 2
  end
end
