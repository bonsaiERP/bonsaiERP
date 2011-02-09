require 'spec_helper'

describe "accounts/edit.html.haml" do
  before(:each) do
    @account = assign(:account, stub_model(Account,
      :name => "MyString",
      :address => "MyString",
      :email => "MyString",
      :website => "MyString",
      :number => "MyString"
    ))
  end

  it "renders the edit account form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => account_path(@account), :method => "post" do
      assert_select "input#account_name", :name => "account[name]"
      assert_select "input#account_address", :name => "account[address]"
      assert_select "input#account_email", :name => "account[email]"
      assert_select "input#account_website", :name => "account[website]"
      assert_select "input#account_number", :name => "account[number]"
    end
  end
end
