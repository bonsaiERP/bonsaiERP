require 'spec_helper'

describe "payments/index.html.haml" do
  before(:each) do
    assign(:payments, [
      stub_model(Payment,
        :amount => "9.99",
        :interests_penalties => "9.99",
        :description => "Description"
      ),
      stub_model(Payment,
        :amount => "9.99",
        :interests_penalties => "9.99",
        :description => "Description"
      )
    ])
  end

  it "renders a list of payments" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
