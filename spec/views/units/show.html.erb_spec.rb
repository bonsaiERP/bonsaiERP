require 'spec_helper'

describe "units/show.html.erb" do
  before(:each) do
    assign(:unit, @unit = stub_model(Unit,
      :name => "MyString",
      :abbreviation => "MyString",
      :description => "MyString",
      :integer => false
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain(false)
  end
end
