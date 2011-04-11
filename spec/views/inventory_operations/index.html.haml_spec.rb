require 'spec_helper'

describe "inventory_operations/index.html.haml" do
  before(:each) do
    assign(:inventory_operations, [
      stub_model(InventoryOperation,
        :ref_number => "Ref Number",
        :cotanct_id => 1,
        :description => "Description"
      ),
      stub_model(InventoryOperation,
        :ref_number => "Ref Number",
        :cotanct_id => 1,
        :description => "Description"
      )
    ])
  end

  it "renders a list of inventory_operations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Ref Number".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
