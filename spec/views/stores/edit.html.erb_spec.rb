require 'spec_helper'

describe "stores/edit.html.erb" do
  before(:each) do
    assign(:store, @store = stub_model(Store,
      :new_record? => false,
      :name => "MyString",
      :address => "MyString",
      :phone => "MyString",
      :active => false,
      :description => "MyString"
    ))
  end

  it "renders the edit store form" do
    render

    rendered.should have_selector("form", :action => store_path(@store), :method => "post") do |form|
      form.should have_selector("input#store_name", :name => "store[name]")
      form.should have_selector("input#store_address", :name => "store[address]")
      form.should have_selector("input#store_phone", :name => "store[phone]")
      form.should have_selector("input#store_active", :name => "store[active]")
      form.should have_selector("input#store_description", :name => "store[description]")
    end
  end
end
