require 'spec_helper'

describe "inventory_operations/edit.html.haml" do
  before(:each) do
    @inventory_operation = assign(:inventory_operation, stub_model(InventoryOperation,
      :ref_number => "MyString",
      :cotanct_id => 1,
      :description => "MyString"
    ))
  end

  it "renders the edit inventory_operation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => inventory_operations_path(@inventory_operation), :method => "post" do
      assert_select "input#inventory_operation_ref_number", :name => "inventory_operation[ref_number]"
      assert_select "input#inventory_operation_cotanct_id", :name => "inventory_operation[cotanct_id]"
      assert_select "input#inventory_operation_description", :name => "inventory_operation[description]"
    end
  end
end
