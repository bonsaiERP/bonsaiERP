require 'spec_helper'

describe "taxes/edit.html.erb" do
  before(:each) do
    assign(:tax, @tax = stub_model(Tax,
      :new_record? => false,
      :name => "MyString",
      :abbreviation => "MyString",
      :rate => "9.99",
      :organisation => nil
    ))
  end

  it "renders the edit tax form" do
    render

    response.should have_selector("form", :action => tax_path(@tax), :method => "post") do |form|
      form.should have_selector("input#tax_name", :name => "tax[name]")
      form.should have_selector("input#tax_abbreviation", :name => "tax[abbreviation]")
      form.should have_selector("input#tax_rate", :name => "tax[rate]")
      form.should have_selector("input#tax_organisation", :name => "tax[organisation]")
    end
  end
end
