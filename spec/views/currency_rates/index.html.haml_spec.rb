require 'spec_helper'

describe "currency_rates/index.html.haml" do
  before(:each) do
    assign(:currency_rates, [
      stub_model(CurrencyRate,
        :rate => "9.99"
      ),
      stub_model(CurrencyRate,
        :rate => "9.99"
      )
    ])
  end

  it "renders a list of currency_rates" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
  end
end
