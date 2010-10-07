require 'spec_helper'

describe "transactions/new.html.haml" do
  before(:each) do
    assign(:transaction, stub_model(Transaction,
      :new_record? => true,
      :contact_id => 1,
      :type => "MyString",
      :total => "9.99",
      :active => false,
      :description => "MyString",
      :state => "MyString",
      :ref_number => "MyString",
      :balance => "9.99"
    ))
  end

  it "renders new transaction form" do
    render

    rendered.should have_selector("form", :action => transactions_path, :method => "post") do |form|
      form.should have_selector("input#transaction_contact_id", :name => "transaction[contact_id]")
      form.should have_selector("input#transaction_type", :name => "transaction[type]")
      form.should have_selector("input#transaction_total", :name => "transaction[total]")
      form.should have_selector("input#transaction_active", :name => "transaction[active]")
      form.should have_selector("input#transaction_description", :name => "transaction[description]")
      form.should have_selector("input#transaction_state", :name => "transaction[state]")
      form.should have_selector("input#transaction_ref_number", :name => "transaction[ref_number]")
      form.should have_selector("input#transaction_balance", :name => "transaction[balance]")
    end
  end
end
