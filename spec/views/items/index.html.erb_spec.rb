require 'spec_helper'

describe "items/index.html.erb" do
  before(:each) do
    assign(:items, [
      stub_model(Item,
        :unit => nil,
        :itemable_id => 1,
        :itemable_type => "MyString",
        :name => "MyString",
        :description => "MyString",
        :type => "MyString",
        :integer => 1,
        :product => false,
        :stockable => false
      ),
      stub_model(Item,
        :unit => nil,
        :itemable_id => 1,
        :itemable_type => "MyString",
        :name => "MyString",
        :description => "MyString",
        :type => "MyString",
        :integer => 1,
        :product => false,
        :stockable => false
      )
    ])
  end

  it "renders a list of items" do
    render
    response.should have_selector("tr>td", :content => nil.to_s, :count => 2)
    response.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    response.should have_selector("tr>td", :content => false.to_s, :count => 2)
    response.should have_selector("tr>td", :content => false.to_s, :count => 2)
  end
end
