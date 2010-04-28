require 'spec_helper'

describe "contacts/edit.html.erb" do
  before(:each) do
    assign(:contact, @contact = stub_model(Contact,
      :new_record? => false,
      :name => "MyString",
      :address => "MyString",
      :adress_alt => "MyString",
      :phone => "MyString",
      :mobile => "MyString",
      :type => "MyString",
      :email => "MyString",
      :nit => "MyString",
      :adicional_info => "MyString"
    ))
  end

  it "renders the edit contact form" do
    render

    response.should have_selector("form", :action => contact_path(@contact), :method => "post") do |form|
      form.should have_selector("input#contact_name", :name => "contact[name]")
      form.should have_selector("input#contact_address", :name => "contact[address]")
      form.should have_selector("input#contact_adress_alt", :name => "contact[adress_alt]")
      form.should have_selector("input#contact_phone", :name => "contact[phone]")
      form.should have_selector("input#contact_mobile", :name => "contact[mobile]")
      form.should have_selector("input#contact_type", :name => "contact[type]")
      form.should have_selector("input#contact_email", :name => "contact[email]")
      form.should have_selector("input#contact_nit", :name => "contact[nit]")
      form.should have_selector("input#contact_adicional_info", :name => "contact[adicional_info]")
    end
  end
end
