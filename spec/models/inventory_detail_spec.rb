require 'spec_helper'

describe InventoryDetail do
  it { should belong_to(:inventory) }
  it { should belong_to(:item) }

  it { should validate_presence_of(:item) }
  it { should validate_presence_of(:item_id) }

  it { should have_valid(:quantity).when(0.1, 1, 100) }
  it { should_not have_valid(:quantity).when(-0.1, nil, 0.0) }
end
