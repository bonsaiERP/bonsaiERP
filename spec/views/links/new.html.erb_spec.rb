require 'spec_helper'

describe "links/new.html.erb" do
  before(:each) do
    assign(:link, stub_model(Link,
      :new_record? => true,
      :name => "MyString",
      :organisation => nil,
      :user => nil,
      :role => "MyString",
      :settings => "MyString"
    ))
  end

  it "renders new link form" do
    render

    response.should have_selector("form", :action => links_path, :method => "post") do |form|
      form.should have_selector("input#link_name", :name => "link[name]")
      form.should have_selector("input#link_organisation", :name => "link[organisation]")
      form.should have_selector("input#link_user", :name => "link[user]")
      form.should have_selector("input#link_role", :name => "link[role]")
      form.should have_selector("input#link_settings", :name => "link[settings]")
    end
  end
end
