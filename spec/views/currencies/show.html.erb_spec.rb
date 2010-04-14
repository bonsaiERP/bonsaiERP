require 'spec_helper'

describe "currencies/show.html.erb" do
  before(:each) do
    assign(:currency, @currency = stub_model(Currency,
      :name => "MyString",
      :symbol => "MyString"
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain("MyString")
    response.should contain("MyString")
  end
end
