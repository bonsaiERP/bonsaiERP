Given /^I create and go to the login page$/ do
  @user = DataSupport::create_user
  visit "/users/confirmation?confirmation_token=#{@user.confirmation_token}"
end

Then /^I fill my email and password$/ do
  fill_in "user[email]", :with => @user.email
  fill_in "user_password", :with => ModelsData::user[:password]

  click_button("Sign in")
end

And /^a list of countries is created$/ do |table|
  table.hashes.each do |country|
    country[:taxes] = eval(country[:taxes])
    Country.create!(country)
  end
end

And /^I fill data with (\w+), (\w+), (\w+), (\w+)$/ do |name, country, address, phone|
  fill_in "organisation_name", :with => name
  select country, :from => "organisation_country_id"
  fill_in "organisation_address", :with => address
  fill_in "organisation_phone", :with => phone

  click_button("Create")
end

Then /^I should see organisation with (\w+), (\w+)$/ do |name, country|
  page.has_content?(name).should == true
  page.has_content?(country).should == true

  country = Country.find_by_name(country)

  country.taxes.each do |v|
    page.has_content?(v[:name]).should == true
    page.has_content?(v[:abbreviation]).should == true
    page.has_content?(v[:rate].to_s).should == true
  end
  
end
