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
    invin.details.size.should eq(0)
  end

  before(:each) do
    UserSession.user = user
    Store.stub_chain(:active, where: [store])
    InventoryDetail.any_instance.stub(item: item)
    Inventory.any_instance.stub(store: store)
    Stock.any_instance.stub(item: item, store: store)
  end

  it "creates" do
    invin = Inventories::In.new(valid_attributes)
    invin.inventory_details.size.should eq(2)

    invin.create.should eq(true)
    io = Inventory.find(invin.inventory.id)
    io.should be_is_a(Inventory)
    io.should be_is_in
    io.creator_id.should eq(user.id)
    io.ref_number.should =~ /\AI-\d{2}-\d{4}\z/

    io.inventory_details.size.should eq(2)
    io.inventory_details.map(&:quantity).should eq([2, 2])
    io.inventory_details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.size.should eq(2)
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([2, 2])

    st = stocks.first
    st.update_attribute(:minimum, 1).should eq(true)
    st_item_id = st.item_id

    # More items
    attrs = valid_attributes.merge(inventory_details_attributes:
      [{item_id: 2, quantity: 2},
       {item_id: 12, quantity: 5}
      ]
    )
    invin = Inventories::In.new(attrs)
    invin.create.should eq(true)
    stocks = Stock.active.where(store_id: io.store_id)
    stocks.size.should eq(3)

    stocks.find {|v| v.item_id === st_item_id}.minimum.should == 1

    stocks.find {|v| v.item_id === 2}.quantity.should == 4
    stocks.find {|v| v.item_id === 12}.quantity.should == 5
    stocks.find {|v| v.item_id === 1}.quantity.should == 2
  end

  it "creates with one item" do
    invin = Inventories::In.new(valid_attributes.merge(
      inventory_details_attributes: [
        {item_id: 1, quantity: 10}, {item_id: 2, quantity: 0},
        {item_id: 3, quantity: ''}, {item_id: 4, quantity: nil}
      ]
    ))

    invin.create.should eq(true)

    inv = Inventory.find(invin.inventory.id)
    inv.inventory_details.size.should eq(1)

    stocks = Stock.active.where(store_id: inv.store_id)
    stocks.size.should eq(1)
    stocks[0].quantity.should == 10
  end
end
