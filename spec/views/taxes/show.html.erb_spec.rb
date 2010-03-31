require 'spec_helper'

describe "taxes/show.html.erb" do
  before(:each) do
    assign(:tax, @tax = stub_model(Tax,
      :name => "MyString",
      :abbreviation => "MyString",
      :rate => "9.99",
      :organisation => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("9.99")
    response.should contain(nil)
  end
end
