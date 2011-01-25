require 'spec_helper'

describe "currency_rates/show.html.haml" do
  before(:each) do
    @currency_rate = assign(:currency_rate, stub_model(CurrencyRate,
      :rate => "9.99"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/9.99/)
  end
end
