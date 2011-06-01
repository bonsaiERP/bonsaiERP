require 'spec_helper'

describe "account_types/edit.html.haml" do
  before(:each) do
    @account_type = assign(:account_type, stub_model(AccountType,
      :name => "MyString",
      :number => "MyString"
    ))
  end

  it "renders the edit account_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => account_types_path(@account_type), :method => "post" do
      assert_select "input#account_type_name", :name => "account_type[name]"
      assert_select "input#account_type_number", :name => "account_type[number]"
    end
  end
end
