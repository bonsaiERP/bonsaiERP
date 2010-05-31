require 'spec_helper'

describe "stores/show.html.erb" do
  before(:each) do
    assign(:store, @store = stub_model(Store,
      :name => "MyString",
      :address => "MyString",
      :phone => "MyString",
      :active => false,
      :description => "MyString"
    ))
  end

  it "renders attributes in <p>" do
    render
   rendered.should contain("MyString")
   rendered.should contain("MyString")
   rendered.should contain("MyString")
   rendered.should contain(false)
   rendered.should contain("MyString")
  end
end
