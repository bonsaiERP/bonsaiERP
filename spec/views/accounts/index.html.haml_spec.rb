require 'spec_helper'

describe "accounts/index.html.haml" do
  before(:each) do
    assign(:accounts, [
      stub_model(Account,
        :name => "Name",
        :address => "Address",
        :email => "Email",
        :website => "Website",
        :number => "Number"
      ),
      stub_model(Account,
        :name => "Name",
        :address => "Address",
        :email => "Email",
        :website => "Website",
        :number => "Number"
      )
    ])
  end

  it "renders a list of accounts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Website".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Number".to_s, :count => 2
  end
end
