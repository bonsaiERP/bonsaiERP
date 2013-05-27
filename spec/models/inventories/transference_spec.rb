# encoding: utf-8
require 'spec_helper'

describe Inventories::Transference do

  let(:store) { build :store, id: 1 }
  let(:store_to) { build :store, id: 2 }

  let(:valid_attributes) {
    {store_id: 1, store_to_id: 2, 
     date: Date.today, description: 'Test transference',
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
    trans = Inventories::Transference.new

    trans.inventory.should be_is_trans
    trans.details.should have(0).item
  end

  it "validates" do
    trans = Inventories::Transference.new
    trans.should_not be_valid

    trans.errors[:store].should_not be_blank
    trans.errors[:store_to].should_not be_blank
  end

  context "create" do
    before(:each) do
      UserSession.user = user
      Store.stub_chain(:active, :where).with(id: 1).and_return([store])
      Store.stub_chain(:active, :where).with(id: 2).and_return([store_to])

      InventoryDetail.any_instance.stub(item: item)
      Inventory.any_instance.stub(store: store)
      Stock.any_instance.stub(item: item, store: store)
    end

    it "creates" do
      trans = Inventories::Transference.new(valid_attributes)
      trans.inventory_details.should have(2).items
      trans.inventory.store_id.should eq(1)
      trans.inventory.store_to_id.should eq(2)

      trans.create.should be_true
      trans = Inventory.find(trans.inventory.id)
      trans.should be_is_a(Inventory)
      trans.should be_is_trans
      trans.creator_id.should eq(user.id)
      trans.ref_number.should =~ /\AT-\d{2}-\d{4}\z/


      trans.inventory_details.should have(2).items
      trans.inventory_details.map(&:quantity).should eq([2, 2])
      trans.inventory_details.map(&:item_id).should eq([1, 2])

      # Stocks from
      stocks = Stock.active.where(store_id: 1)
      stocks.should have(2).items
      stocks.map(&:item_id).sort.should eq([1, 2])
      stocks.map(&:quantity).should eq([-2, -2])

      # Stocks to
      stocks = Stock.active.where(store_id: 2)
      stocks.should have(2).items
      stocks.map(&:item_id).sort.should eq([1, 2])
      stocks.map(&:quantity).should eq([2, 2])

      ## More items
      #attrs = valid_attributes.merge(inventory_details_attributes:
      #  [{item_id: 2, quantity: 2},
      #   {item_id: 12, quantity: 5}
      #  ]
      #)
      #invin = Inventories::In.new(attrs)
      #invin.create.should be_true
      #stocks = Stock.active.where(store_id: io.store_id)
      #stocks.should have(3).items

      #stocks.find {|v| v.item_id === 2}.quantity.should == 4
      #stocks.find {|v| v.item_id === 12}.quantity.should == 5
      #stocks.find {|v| v.item_id === 1}.quantity.should == 2
    end

    it "creates with one item" do
      invin = Inventories::In.new(valid_attributes.merge(
        inventory_details_attributes: [
          {item_id: 1, quantity: 10}, {item_id: 2, quantity: 0},
          {item_id: 3, quantity: ''}, {item_id: 4, quantity: nil}
        ]
      ))

      invin.create.should be_true

      inv = Inventory.find(invin.inventory.id)
      inv.inventory_details.should have(1).items

      stocks = Stock.active.where(store_id: inv.store_id)
      stocks.should have(1).item
      stocks[0].quantity.should == 10
    end
  end
end
