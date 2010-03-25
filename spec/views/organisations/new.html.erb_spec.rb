require 'spec_helper'

describe "organisations/new.html.erb" do
  before(:each) do
    assign(:organisation, stub_model(Organisation,
      :new_record? => true,
      :user => nil,
      :country => nil,
      :name => "MyString",
      :address => "MyString",
      :address_alt => "MyString",
      :phone => "MyString",
      :phone_alt => "MyString",
      :mobile => "MyString",
      :email => "MyString",
      :website => "MyString"
    ))
  end

  it "renders new organisation form" do
    render

    response.should have_selector("form", :action => organisations_path, :method => "post") do |form|
      form.should have_selector("input#organisation_user", :name => "organisation[user]")
      form.should have_selector("input#organisation_country", :name => "organisation[country]")
      form.should have_selector("input#organisation_name", :name => "organisation[name]")
      form.should have_selector("input#organisation_address", :name => "organisation[address]")
      form.should have_selector("input#organisation_address_alt", :name => "organisation[address_alt]")
      form.should have_selector("input#organisation_phone", :name => "organisation[phone]")
      form.should have_selector("input#organisation_phone_alt", :name => "organisation[phone_alt]")
      form.should have_selector("input#organisation_mobile", :name => "organisation[mobile]")
      form.should have_selector("input#organisation_email", :name => "organisation[email]")
      form.should have_selector("input#organisation_website", :name => "organisation[website]")
    end
  end
end
