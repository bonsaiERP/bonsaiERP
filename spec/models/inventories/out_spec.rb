# encoding: utf-8
require 'spec_helper'

describe Inventories::Out do
  let(:store) { build :store, id: 1 }
  let(:valid_attributes) {
    {store_id: 1, date: Date.today, description: 'Test inventory out',
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
    invout = Inventories::Out.new

    invout.inventory.should be_is_out
  end

  context "create" do
    before(:each) do
      UserSession.user = user
      Store.stub_chain(:active, where: [store])
    end

    def create_inventory_in
      inv = Inventories::In.new(valid_attributes.merge({
        inventory_details_attributes: [
          {item_id: 1, quantity: 2},
          {item_id: 2, quantity: 2},
          {item_id: 10, quantity: 2}
        ]
      }))
      inv.create
    end

    it "creates" do
      InventoryDetail.any_instance.stub(item: item)
      Inventory.any_instance.stub(store: store)
      Stock.any_instance.stub(item: item, store: store)

      # Create with the function
      create_inventory_in.should eq(true)


      # Create
      invout = Inventories::Out.new(valid_attributes)
      invout.create.should eq(true)

      io = Inventory.find(invout.inventory.id)
      io.should be_is_a(Inventory)
      io.should be_is_out
      io.creator_id.should eq(user.id)
      io.ref_number.should =~ /\AE-\d{2}-\d{4}\z/

      io.inventory_details.size.should eq(2)
      io.inventory_details.map(&:quantity).should eq([2, 2])
      io.inventory_details.map(&:item_id).should eq([1, 2])

      stocks = Stock.active.where(store_id: io.store_id, item_id: [1, 2])
      stocks.size.should eq(2)
      stocks.map(&:item_id).sort.should eq([1, 2])
      stocks.map(&:quantity).should eq([0, 0])

      st = stocks.first
      st.update_attribute(:minimum, 1).should eq(true)
      st_item_id = st.item_id

      # More items ERROR repeated
      attrs = valid_attributes.merge(inventory_details_attributes:
        [{item_id: 2, quantity: 2, store_id: 1},
         {item_id: 120, quantity: 5, store_id: 1},
         {item_id: 2, quantity: 10, store_id: 1}
        ]
      )
      invout = Inventories::Out.new(attrs)
      invout.create.should eq(false)
      invout.details[2].errors[:item_id].should_not be_blank

      # More items store with ERROR
      attrs = valid_attributes.merge(inventory_details_attributes:
        [{item_id: 2, quantity: 2, store_id: 1},
         {item_id: 10, quantity: 5, store_id: 1}
        ]
      )
      invout = Inventories::Out.new(attrs)
$glob =true
      invout.create.should eq(true)

      inv = Inventory.find(invout.inventory.id)

      inv.should be_has_error

      inv.error_messages["quantity"].should eq(['inventory.negative_stock'])
      inv.error_messages["item_ids"].should eq([2, 10])

      stocks = Stock.active.where(store_id: io.store_id)
      stocks.size.should eq(3)

      stocks.find {|v| v.item_id === st_item_id}.minimum.should == 1

      stocks.find {|v| v.item_id === 1}.quantity.should == 0
      stocks.find {|v| v.item_id === 2}.quantity.should == -2
      stocks.find {|v| v.item_id === 10}.quantity.should == -3
    end
  end
end
