require 'spec_helper'

describe "projects/show.html.haml" do
  before(:each) do
    @project = assign(:project, stub_model(Project,
      :name => "Name",
      :active => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
  end
end
