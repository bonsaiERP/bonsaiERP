require 'spec_helper'

describe "currencies/index.html.erb" do
  before(:each) do
    assign(:currencies, [
      stub_model(Currency,
        :name => "MyString",
        :symbol => "MyString"
      ),
      stub_model(Currency,
        :name => "MyString",
        :symbol => "MyString"
      )
    ])
  end

  it "renders a list of currencies" do
    render
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
  end
end
