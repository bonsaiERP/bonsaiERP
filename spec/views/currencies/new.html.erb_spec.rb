require 'spec_helper'

describe "currencies/new.html.erb" do
  before(:each) do
    assign(:currency, stub_model(Currency,
      :new_record? => true,
      :name => "MyString",
      :symbol => "MyString"
    ))
  end

  it "renders new currency form" do
    render

    response.should have_selector("form", :action => currencies_path, :method => "post") do |form|
      form.should have_selector("input#currency_name", :name => "currency[name]")
      form.should have_selector("input#currency_symbol", :name => "currency[symbol]")
    end
  end
end
