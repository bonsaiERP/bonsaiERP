require 'spec_helper'

describe "links/index.html.erb" do
  before(:each) do
    assign(:links, [
      stub_model(Link,
        :name => "MyString",
        :organisation => nil,
        :user => nil,
        :role => "MyString",
        :settings => "MyString"
      ),
      stub_model(Link,
        :name => "MyString",
        :organisation => nil,
        :user => nil,
        :role => "MyString",
        :settings => "MyString"
      )
    ])
  end

  it "renders a list of links" do
    render
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => nil.to_s, :count => 2)
    response.should have_selector("tr>td", :content => nil.to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
  end
end
