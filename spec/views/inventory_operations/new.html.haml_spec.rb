require 'spec_helper'

describe "inventory_operations/new.html.haml" do
  before(:each) do
    assign(:inventory_operation, stub_model(InventoryOperation,
      :ref_number => "MyString",
      :cotanct_id => 1,
      :description => "MyString"
    ).as_new_record)
  end

  it "renders new inventory_operation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => inventory_operations_path, :method => "post" do
      assert_select "input#inventory_operation_ref_number", :name => "inventory_operation[ref_number]"
      assert_select "input#inventory_operation_cotanct_id", :name => "inventory_operation[cotanct_id]"
      assert_select "input#inventory_operation_description", :name => "inventory_operation[description]"
    end
  end
end
