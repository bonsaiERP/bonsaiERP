# Create data to test
Given /I create one organisation (\w+)/ do |org|
  unless Organisation.find_by_name(org)
    organisation = DataSupport::create_organisation(org)
    organisation.name.should == org
  end
  Organisation.all.size.should == 1
end

# Step to login with defined user
Then /I login/ do
  visit "/users/sign_out"
  visit "/users/sign_in"
  fill_in "user[email]", :with => 'boris@example.com'
  fill_in "user_password", :with => 'demo123'

  click_button("Sign in")
end

And /I click the ([\w\s]+) link/ do |link|
  click_link(link)
end


Then /I fill the item form with ([a-zA-Z\s]+), (\w+), (\w+), (\w+)/ do |name, unit, product, stockable|
  fill_in("item_name", :with => name)
  select unit, :from => "item_unit_id"
  check("item_product") if product == 'true' 
  check("item_stockable") if stockable == 'true'

  click_button("Create")
end

And /should see item with ([a-zA-Z\s]+), (\w+), (\w+), (\w+)/ do |name, unit, product, stockable|
  item = Item.find_by_name(name)
  item.name.should == name
  item.unit.name.should == unit
  item.product.should == (product == 'true')
  item.stockable.should == (stockable == 'true')

  page.has_content?(name).should == true
  page.has_content?(unit).should == true
  #page.should have_css("p.item_product", :text => bonsai?(product=='true')) #has_content?(product).should == true
  #page.should have_css("p.item_stockable")
end
