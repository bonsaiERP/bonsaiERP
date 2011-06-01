require 'spec_helper'

describe "account_types/new.html.haml" do
  before(:each) do
    assign(:account_type, stub_model(AccountType,
      :name => "MyString",
      :number => "MyString"
    ).as_new_record)
  end

  it "renders new account_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => account_types_path, :method => "post" do
      assert_select "input#account_type_name", :name => "account_type[name]"
      assert_select "input#account_type_number", :name => "account_type[number]"
    end
  end
end
