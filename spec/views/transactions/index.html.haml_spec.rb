require 'spec_helper'

describe "transactions/index.html.haml" do
  before(:each) do
    assign(:transactions, [
      stub_model(Transaction,
        :contact_id => 1,
        :type => "Type",
        :total => "9.99",
        :active => false,
        :description => "Description",
        :state => "State",
        :ref_number => "Ref Number",
        :balance => "9.99"
      ),
      stub_model(Transaction,
        :contact_id => 1,
        :type => "Type",
        :total => "9.99",
        :active => false,
        :description => "Description",
        :state => "State",
        :ref_number => "Ref Number",
        :balance => "9.99"
      )
    ])
  end

  it "renders a list of transactions" do
    render
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Type".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "9.99".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => false.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Description".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "State".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Ref Number".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "9.99".to_s, :count => 2)
  end
end
