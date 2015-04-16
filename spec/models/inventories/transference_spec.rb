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
    trans.details.size.should eq(0)
    trans.details_form_name.should eq('inventories_transference[inventory_details_attributes]')
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
      attrs = valid_attributes.dup
      attrs.delete(:store_to_id)
      attrs[:inventory_details_attributes][1][:quantity] = 10
      invin = Inventories::In.new(attrs)
      invin.create.should eq(true)

      stocks = Stock.active.where(store_id: attrs[:store_id])

      stocks.map(&:item_id).should eq([1, 2])
      stocks.map(&:quantity).should eq([2, 10])

      st = stocks.last
      st.update_attribute(:minimum, 4).should eq(true)
      st_item_id = st.item_id

      # I don't understand but must change to original manually
      attrs[:inventory_details_attributes][1][:quantity] = 2

      trans = Inventories::Transference.new(valid_attributes)
      trans.inventory_details.size.should eq(2)
      trans.inventory.store_id.should eq(1)
      #trans.inventory.store_to_id.should eq(2)

      trans.create.should eq(true)
      trans.inventory.store_to_id.should eq(2)
      inv = Inventory.find(trans.inventory.id)
      inv.should be_is_a(Inventory)
      inv.should be_is_trans
      inv.creator_id.should eq(user.id)
      inv.ref_number.should =~ /\AT-\d{2}-\d{4}\z/

      inv.inventory_details.size.should eq(2)
      inv.inventory_details.map(&:quantity).should eq([2, 2])
      inv.inventory_details.map(&:item_id).should eq([1, 2])

      # Stocks from

      stocks = Stock.active.where(store_id: 1)
      stocks.find {|v| v.item_id === st_item_id}.minimum.should == 4

      stocks.size.should eq(2)
      stocks.map(&:item_id).sort.should eq([1, 2])
      stocks.map(&:quantity).should eq([0, 8])

      # Stocks to
      stocks = Stock.active.where(store_id: 2)
      stocks.size.should eq(2)
      stocks.map(&:item_id).sort.should eq([1, 2])

      stocks.map(&:quantity).should eq([2, 2])

      st = stocks.find {|v| v.item_id === st_item_id}
      st.update_attribute(:minimum, 0.5).should eq(true)

      # More items
      attrs = valid_attributes.merge(inventory_details_attributes:
        [{item_id: st_item_id, quantity: 2}]
      )
      inv = Inventories::Transference.new(attrs)
      inv.create.should eq(true)

      # From
      stocks = Stock.active.where(store_id: 1)
      stocks.find {|v| v.item_id === st_item_id}.minimum.should == 4
      stocks.find {|v| v.item_id === st_item_id}.quantity.should == 6

      # To
      stocks = Stock.active.where(store_id: 2)
      stocks.find {|v| v.item_id === st_item_id}.minimum.should == 0.5
      stocks.find {|v| v.item_id === st_item_id}.quantity.should == 4
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
end
