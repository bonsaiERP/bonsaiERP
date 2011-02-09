require 'spec_helper'

describe "currency_rates/new.html.haml" do
  before(:each) do
    assign(:currency_rate, stub_model(CurrencyRate,
      :rate => "9.99"
    ).as_new_record)
  end

  it "renders new currency_rate form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => currency_rates_path, :method => "post" do
      assert_select "input#currency_rate_rate", :name => "currency_rate[rate]"
    end
  end
end
