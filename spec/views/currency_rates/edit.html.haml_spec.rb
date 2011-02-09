require 'spec_helper'

describe "currency_rates/edit.html.haml" do
  before(:each) do
    @currency_rate = assign(:currency_rate, stub_model(CurrencyRate,
      :rate => "9.99"
    ))
  end

  it "renders the edit currency_rate form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => currency_rate_path(@currency_rate), :method => "post" do
      assert_select "input#currency_rate_rate", :name => "currency_rate[rate]"
    end
  end
end
