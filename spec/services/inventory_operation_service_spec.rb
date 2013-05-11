# encoding: utf-8
require 'spec_helper'

describe InventoryOperationService do
  let(:store) { build :store, id: 1 }
  let(:valid_attributes) {
    {store_id: 1}
  }

  it 'invalid' do
    io = InventoryOperationService.new(store_id: 1)
    io.should_not be_valid
  end

  it "Valid" do
    io = InventoryOperationService.new(store_id: 1)
    io.stub(store: store)
    io.should be_valid
  end

  it "#inventory_operation_operation" do
    io = InventoryOperationService.new
    io.inventory_operation.should be_is_a(InventoryOperation)
  end

  describe 'Delegates and related' do
    subject { InventoryOperationService.new }

    it "builds inventory_operation_details" do
      subject.inventory_operation_details.build
      subject.inventory_operation_details.should have(1).item

      subject.inventory_operation_details.build
      subject.inventory_operation_details.should have(2).items

      subject.inventory_operation.inventory_operation_details.should eq(subject.inventory_operation_details)
    end
  end

  it "#store" do
    Store.should_receive(:where).with(id: 3).and_return([true])
    Store.should_receive(:active).and_return(Store)

    InventoryOperationService.new(store_id: 3).store
  end
end
