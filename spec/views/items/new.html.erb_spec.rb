require 'spec_helper'

describe "items/new.html.erb" do
  before(:each) do
    assign(:item, stub_model(Item,
      :new_record? => true,
      :unit => nil,
      :itemable_id => 1,
      :itemable_type => "MyString",
      :name => "MyString",
      :description => "MyString",
      :type => "MyString",
      :integer => 1,
      :product => false,
      :stockable => false
    ))
  end

  it "renders new item form" do
    render

    response.should have_selector("form", :action => items_path, :method => "post") do |form|
      form.should have_selector("input#item_unit", :name => "item[unit]")
      form.should have_selector("input#item_itemable_id", :name => "item[itemable_id]")
      form.should have_selector("input#item_itemable_type", :name => "item[itemable_type]")
      form.should have_selector("input#item_name", :name => "item[name]")
      form.should have_selector("input#item_description", :name => "item[description]")
      form.should have_selector("input#item_type", :name => "item[type]")
      form.should have_selector("input#item_integer", :name => "item[integer]")
      form.should have_selector("input#item_product", :name => "item[product]")
      form.should have_selector("input#item_stockable", :name => "item[stockable]")
    end
  end
end
