require 'spec_helper'

describe InventoryOperation do
  it { should belong_to(:store) }
  it { should belong_to(:contact) }
  it { should belong_to(:creator) }
  it { should belong_to(:project) }

  it { should have_many(:inventory_operation_details) }
  it { should accept_nested_attributes_for(:inventory_operation_details) }

  it { should validate_presence_of(:ref_number) }
  it { should validate_presence_of(:store) }
  it { should validate_presence_of(:store_id) }

  it { should have_valid(:operation).when(*InventoryOperation::OPERATIONS) }
  it { should_not have_valid(:operation).when('je', '') }
end
