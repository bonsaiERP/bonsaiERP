require 'spec_helper'

describe "units/new.html.erb" do
  before(:each) do
    assign(:unit, stub_model(Unit,
      :new_record? => true,
      :name => "MyString",
      :abbreviation => "MyString",
      :description => "MyString",
      :integer => false
    ))
  end

  it "renders new unit form" do
    render

    response.should have_selector("form", :action => units_path, :method => "post") do |form|
      form.should have_selector("input#unit_name", :name => "unit[name]")
      form.should have_selector("input#unit_abbreviation", :name => "unit[abbreviation]")
      form.should have_selector("input#unit_description", :name => "unit[description]")
      form.should have_selector("input#unit_integer", :name => "unit[integer]")
    end
  end
end
