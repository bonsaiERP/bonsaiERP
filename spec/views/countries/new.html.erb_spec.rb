require 'spec_helper'

describe "countries/new.html.erb" do
  before(:each) do
    assign(:country, stub_model(Country,
      :new_record? => true,
      :name => "MyString",
      :abreviation => "MyString"
    ))
  end

  it "renders new country form" do
    render

    response.should have_selector("form", :action => countries_path, :method => "post") do |form|
      form.should have_selector("input#country_name", :name => "country[name]")
      form.should have_selector("input#country_abreviation", :name => "country[abreviation]")
    end
  end
end
