# encoding: utf-8
require 'spec_helper'

describe Inventories::Form do
  let(:store) { build :store, id: 1 }
  let(:valid_attributes) {
    {store_id: 1}
  }

  it 'invalid' do
    io = Inventories::Form.new(store_id: 1)
    io.should_not be_valid
  end

  it "Valid" do
    io = Inventories::Form.new(store_id: 1, inventory_details_attributes: [{item_id: 1, quantity: 2}])
    InventoryDetail.any_instance.stub(item: true)
    io.stub(store: store)
    io.should be_valid
  end

  it "#inventory_operation" do
    io = Inventories::Form.new
    io.inventory.should be_is_a(Inventory)
  end

  describe 'Delegates and related' do
    subject { Inventories::Form.new }

    it "builds inventory_details" do
      subject.inventory_details.build
      subject.inventory_details.size.should eq(1)

      subject.inventory_details.build
      subject.inventory_details.size.should eq(2)

      subject.inventory.inventory_details.should eq(subject.inventory_details)
    end
  end

  it "#store" do
    Store.should_receive(:where).with(id: 3).and_return([true])
    Store.should_receive(:active).and_return(Store)

    Inventories::Form.new(store_id: 3).store
  end
end
