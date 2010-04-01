require 'spec_helper'

describe "links/show.html.erb" do
  before(:each) do
    assign(:link, @link = stub_model(Link,
      :name => "MyString",
      :organisation => nil,
      :user => nil,
      :role => "MyString",
      :settings => "MyString"
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain("MyString")
    response.should contain(nil)
    response.should contain(nil)
    response.should contain("MyString")
    response.should contain("MyString")
  end
end
