require 'spec_helper'

describe "countries/index.html.erb" do
  before(:each) do
    assign(:countries, [
      stub_model(Country,
        :name => "MyString",
        :abreviation => "MyString"
      ),
      stub_model(Country,
        :name => "MyString",
        :abreviation => "MyString"
      )
    ])
  end

  it "renders a list of countries" do
    render
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
  end
end
