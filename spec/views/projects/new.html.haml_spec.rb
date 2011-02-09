require 'spec_helper'

describe "projects/new.html.haml" do
  before(:each) do
    assign(:project, stub_model(Project,
      :name => "MyString",
      :active => false
    ).as_new_record)
  end

  it "renders new project form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => projects_path, :method => "post" do
      assert_select "input#project_name", :name => "project[name]"
      assert_select "input#project_active", :name => "project[active]"
    end
  end
end
