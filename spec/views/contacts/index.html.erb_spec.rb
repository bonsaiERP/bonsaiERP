require 'spec_helper'

describe "contacts/index.html.erb" do
  before(:each) do
    assign(:contacts, [
      stub_model(Contact,
        :name => "MyString",
        :address => "MyString",
        :adress_alt => "MyString",
        :phone => "MyString",
        :mobile => "MyString",
        :type => "MyString",
        :email => "MyString",
        :nit => "MyString",
        :adicional_info => "MyString"
      ),
      stub_model(Contact,
        :name => "MyString",
        :address => "MyString",
        :adress_alt => "MyString",
        :phone => "MyString",
        :mobile => "MyString",
        :type => "MyString",
        :email => "MyString",
        :nit => "MyString",
        :adicional_info => "MyString"
      )
    ])
  end

  it "renders a list of contacts" do
    render
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
  end
end
