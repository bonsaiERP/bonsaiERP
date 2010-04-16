require 'spec_helper'

describe "units/edit.html.erb" do
  before(:each) do
    assign(:unit, @unit = stub_model(Unit,
      :new_record? => false,
      :name => "MyString",
      :abbreviation => "MyString",
      :description => "MyString",
      :integer => false
    ))
  end

  it "renders the edit unit form" do
    render

    response.should have_selector("form", :action => unit_path(@unit), :method => "post") do |form|
      form.should have_selector("input#unit_name", :name => "unit[name]")
      form.should have_selector("input#unit_abbreviation", :name => "unit[abbreviation]")
      form.should have_selector("input#unit_description", :name => "unit[description]")
      form.should have_selector("input#unit_integer", :name => "unit[integer]")
    end
  end
end
