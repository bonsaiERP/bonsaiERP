require 'spec_helper'

describe "organisations/index.html.erb" do
  before(:each) do
    assign(:organisations, [
      stub_model(Organisation,
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
      ),
      stub_model(Organisation,
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
      )
    ])
  end

  it "renders a list of organisations" do
    render
    response.should have_selector("tr>td", :content => nil.to_s, :count => 2)
    response.should have_selector("tr>td", :content => nil.to_s, :count => 2)
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
