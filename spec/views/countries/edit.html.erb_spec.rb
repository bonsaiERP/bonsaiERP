require 'spec_helper'

describe "countries/edit.html.erb" do
  before(:each) do
    assign(:country, @country = stub_model(Country,
      :new_record? => false,
      :name => "MyString",
      :abreviation => "MyString"
    ))
  end

  it "renders the edit country form" do
    render

    response.should have_selector("form", :action => country_path(@country), :method => "post") do |form|
      form.should have_selector("input#country_name", :name => "country[name]")
      form.should have_selector("input#country_abreviation", :name => "country[abreviation]")
    end
  end
end
