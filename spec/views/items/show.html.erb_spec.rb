require 'spec_helper'

describe "items/show.html.erb" do
  before(:each) do
    assign(:item, @item = stub_model(Item,
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

  it "renders attributes in <p>" do
    render
    response.should contain(nil)
    response.should contain(1)
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain(1)
    response.should contain(false)
    response.should contain(false)
  end
end
