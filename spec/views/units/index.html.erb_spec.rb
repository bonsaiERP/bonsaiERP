require 'spec_helper'

describe "units/index.html.erb" do
  before(:each) do
    assign(:units, [
      stub_model(Unit,
        :name => "MyString",
        :abbreviation => "MyString",
        :description => "MyString",
        :integer => false
      ),
      stub_model(Unit,
        :name => "MyString",
        :abbreviation => "MyString",
        :description => "MyString",
        :integer => false
      )
    ])
  end

  it "renders a list of units" do
    render
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => false.to_s, :count => 2)
  end
end
