require 'spec_helper'

describe "contacts/show.html.erb" do
  before(:each) do
    assign(:contact, @contact = stub_model(Contact,
      :name => "MyString",
      :address => "MyString",
      :adress_alt => "MyString",
      :phone => "MyString",
      :mobile => "MyString",
      :type => "MyString",
      :email => "MyString",
      :nit => "MyString",
      :adicional_info => "MyString"
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain("MyString")
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
