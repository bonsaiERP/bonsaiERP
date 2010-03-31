require 'spec_helper'

describe "taxes/index.html.erb" do
  before(:each) do
    assign(:taxes, [
      stub_model(Tax,
        :name => "MyString",
        :abbreviation => "MyString",
        :rate => "9.99",
        :organisation => nil
      ),
      stub_model(Tax,
        :name => "MyString",
        :abbreviation => "MyString",
        :rate => "9.99",
        :organisation => nil
      )
    ])
  end

  it "renders a list of taxes" do
    render
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "9.99".to_s, :count => 2)
    response.should have_selector("tr>td", :content => nil.to_s, :count => 2)
  end
end
