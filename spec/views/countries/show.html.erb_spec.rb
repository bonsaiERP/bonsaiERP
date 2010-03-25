require 'spec_helper'

describe "countries/show.html.erb" do
  before(:each) do
    assign(:country, @country = stub_model(Country,
      :name => "MyString",
      :abreviation => "MyString"
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain("MyString")
    response.should contain("MyString")
  end
end
