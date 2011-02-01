require 'spec_helper'

describe "accounts/show.html.haml" do
  before(:each) do
    @account = assign(:account, stub_model(Account,
      :name => "Name",
      :address => "Address",
      :email => "Email",
      :website => "Website",
      :number => "Number"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Address/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Email/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Website/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Number/)
  end
end
