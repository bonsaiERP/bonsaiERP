require 'spec_helper'

describe "payments/new.html.haml" do
  before(:each) do
    assign(:payment, stub_model(Payment,
      :amount => "9.99",
      :interests_penalties => "9.99",
      :description => "MyString"
    ).as_new_record)
  end

  it "renders new payment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => payments_path, :method => "post" do
      assert_select "input#payment_amount", :name => "payment[amount]"
      assert_select "input#payment_interests_penalties", :name => "payment[interests_penalties]"
      assert_select "input#payment_description", :name => "payment[description]"
    end
  end
end
