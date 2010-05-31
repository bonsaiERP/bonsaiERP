require 'spec_helper'

describe "stores/new.html.erb" do
  before(:each) do
    assign(:store, stub_model(Store,
      :new_record? => true,
      :name => "MyString",
      :address => "MyString",
      :phone => "MyString",
      :active => false,
      :description => "MyString"
    ))
  end

  it "renders new store form" do
    render

    rendered.should have_selector("form", :action => stores_path, :method => "post") do |form|
      form.should have_selector("input#store_name", :name => "store[name]")
      form.should have_selector("input#store_address", :name => "store[address]")
      form.should have_selector("input#store_phone", :name => "store[phone]")
      form.should have_selector("input#store_active", :name => "store[active]")
      form.should have_selector("input#store_description", :name => "store[description]")
    end
  end
end
