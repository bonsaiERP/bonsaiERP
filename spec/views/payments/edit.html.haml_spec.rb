require 'spec_helper'

describe "payments/edit.html.haml" do
  before(:each) do
    @payment = assign(:payment, stub_model(Payment,
      :amount => "9.99",
      :interests_penalties => "9.99",
      :description => "MyString"
    ))
  end

  it "renders the edit payment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => payment_path(@payment), :method => "post" do
      assert_select "input#payment_amount", :name => "payment[amount]"
      assert_select "input#payment_interests_penalties", :name => "payment[interests_penalties]"
      assert_select "input#payment_description", :name => "payment[description]"
    end
  end
end
