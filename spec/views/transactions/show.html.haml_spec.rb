require 'spec_helper'

describe "transactions/show.html.haml" do
  before(:each) do
    @transaction = assign(:transaction, stub_model(Transaction,
      :contact_id => 1,
      :type => "Type",
      :total => "9.99",
      :active => false,
      :description => "Description",
      :state => "State",
      :ref_number => "Ref Number",
      :balance => "9.99"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain(1.to_s)
    rendered.should contain("Type".to_s)
    rendered.should contain("9.99".to_s)
    rendered.should contain(false.to_s)
    rendered.should contain("Description".to_s)
    rendered.should contain("State".to_s)
    rendered.should contain("Ref Number".to_s)
    rendered.should contain("9.99".to_s)
  end
end
