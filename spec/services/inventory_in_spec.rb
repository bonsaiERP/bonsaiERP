# encoding: utf-8
require 'spec_helper'

describe InventoryIn do
  let(:store) { build :store, id: 1 }
  let(:valid_attributes) {
    {store_id: 1, date: Date.today, description: 'Test inventory in',
     inventory_operation_details_attributes: [
       {item_id: 1, quantity: 2},
       {item_id: 2, quantity: 2}
    ]
    }
  }
  let(:item) { build :item }
  let(:store) { build :store }
  let(:user) { build :user, id: 10 }

  it "#initialize" do
    invin = InventoryIn.new

    invin.inventory_operation.should be_is_invin
  end

  before(:each) do
    UserSession.user = user
  end

  it "creates" do
    InventoryOperationDetail.any_instance.stub(item: item)
    InventoryOperation.any_instance.stub(store: store)
    Stock.any_instance.stub(item: item, store: store)

    invin = InventoryIn.new(valid_attributes)
    invin.inventory_operation_details.should have(2).items

    invin.create.should be_true
    io = InventoryOperation.find(invin.inventory_operation.id)
    io.should be_is_a(InventoryOperation)
    io.should be_is_invin
    io.creator_id.should eq(user.id)
    io.ref_number.should =~ /\AIng-\d{2}-\d{4}\z/

    io.inventory_operation_details.should have(2).items
    io.inventory_operation_details.map(&:quantity).should eq([2, 2])
    io.inventory_operation_details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([2, 2])

    # More items
    attrs = valid_attributes.merge(inventory_operation_details_attributes:
      [{item_id: 2, quantity: 2, store_id: 1},
       {item_id: 12, quantity: 5, store_id: 1},
       {item_id: 2, quantity: 10, store_id: 1}
      ]
    )
    invin = InventoryIn.new(attrs)
    invin.create.should be_true
    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(3).items

    stocks.find {|v| v.item_id === 2}.quantity.should == 14
    stocks.find {|v| v.item_id === 12}.quantity.should == 5
    stocks.find {|v| v.item_id === 1}.quantity.should == 2
  end
end
