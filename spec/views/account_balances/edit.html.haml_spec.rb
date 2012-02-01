require 'spec_helper'

describe "account_balances/edit" do
  before(:each) do
    @account_balance = assign(:account_balance, stub_model(AccountBalance,
      :amount => "9.99",
      :user_id => 1,
      :old_amount => "9.99"
    ))
  end

  it "renders the edit account_balance form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => account_balances_path(@account_balance), :method => "post" do
      assert_select "input#account_balance_amount", :name => "account_balance[amount]"
      assert_select "input#account_balance_user_id", :name => "account_balance[user_id]"
      assert_select "input#account_balance_old_amount", :name => "account_balance[old_amount]"
    end
  end
end
