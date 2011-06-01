require 'spec_helper'

describe "account_types/index.html.haml" do
  before(:each) do
    assign(:account_types, [
      stub_model(AccountType,
        :name => "Name",
        :number => "Number"
      ),
      stub_model(AccountType,
        :name => "Name",
        :number => "Number"
      )
    ])
  end

  it "renders a list of account_types" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Number".to_s, :count => 2
  end
end
