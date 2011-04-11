require 'spec_helper'

describe "inventory_operations/show.html.haml" do
  before(:each) do
    @inventory_operation = assign(:inventory_operation, stub_model(InventoryOperation,
      :ref_number => "Ref Number",
      :cotanct_id => 1,
      :description => "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Ref Number/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Description/)
  end
end
