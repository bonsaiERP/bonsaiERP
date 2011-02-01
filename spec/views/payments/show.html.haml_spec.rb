require 'spec_helper'

describe "payments/show.html.haml" do
  before(:each) do
    @payment = assign(:payment, stub_model(Payment,
      :amount => "9.99",
      :interests_penalties => "9.99",
      :description => "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/9.99/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/9.99/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Description/)
  end
end
