require 'spec_helper'

describe InventoryOperationDetail do
  it { should belong_to(:inventory_operation) }
  it { should belong_to(:item) }

  it { should validate_presence_of(:inventory_operation) }
  it { should validate_presence_of(:inventory_operation_id) }
  it { should validate_presence_of(:item) }
  it { should validate_presence_of(:item_id) }

  it { should have_valid(:quantity).when(0.1, 1, 100) }
  it { should_not have_valid(:quantity).when(-0.1, 0.0, nil) }
end
