require 'spec_helper'

describe "organisations/show.html.erb" do
  before(:each) do
    assign(:organisation, @organisation = stub_model(Organisation,
      :user => nil,
      :country => nil,
      :name => "MyString",
      :address => "MyString",
      :address_alt => "MyString",
      :phone => "MyString",
      :phone_alt => "MyString",
      :mobile => "MyString",
      :email => "MyString",
      :website => "MyString"
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain(nil)
    response.should contain(nil)
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
  end
end
