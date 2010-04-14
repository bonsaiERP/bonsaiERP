require 'spec_helper'

describe "currencies/edit.html.erb" do
  before(:each) do
    assign(:currency, @currency = stub_model(Currency,
      :new_record? => false,
      :name => "MyString",
      :symbol => "MyString"
    ))
  end

  it "renders the edit currency form" do
    render

    response.should have_selector("form", :action => currency_path(@currency), :method => "post") do |form|
      form.should have_selector("input#currency_name", :name => "currency[name]")
      form.should have_selector("input#currency_symbol", :name => "currency[symbol]")
    end
  end
end
