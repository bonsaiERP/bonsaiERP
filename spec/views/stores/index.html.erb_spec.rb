require 'spec_helper'

describe "stores/index.html.erb" do
  before(:each) do
    assign(:stores, [
      stub_model(Store,
        :name => "MyString",
        :address => "MyString",
        :phone => "MyString",
        :active => false,
        :description => "MyString"
      ),
      stub_model(Store,
        :name => "MyString",
        :address => "MyString",
        :phone => "MyString",
        :active => false,
        :description => "MyString"
      )
    ])
  end

  it "renders a list of stores" do
    render
    rendered.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => false.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
  end
end
