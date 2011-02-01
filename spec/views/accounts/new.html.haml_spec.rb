require 'spec_helper'

describe "accounts/new.html.haml" do
  before(:each) do
    assign(:account, stub_model(Account,
      :name => "MyString",
      :address => "MyString",
      :email => "MyString",
      :website => "MyString",
      :number => "MyString"
    ).as_new_record)
  end

  it "renders new account form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => accounts_path, :method => "post" do
      assert_select "input#account_name", :name => "account[name]"
      assert_select "input#account_address", :name => "account[address]"
      assert_select "input#account_email", :name => "account[email]"
      assert_select "input#account_website", :name => "account[website]"
      assert_select "input#account_number", :name => "account[number]"
    end
  end
end
