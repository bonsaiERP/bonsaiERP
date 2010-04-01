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
  organisation = Organisation.last

  # Show taxes added in Organisation callback
  organisation.country.taxes.each do |v|
    page.has_content?(v[:name]).should == true
    page.has_content?(v[:abbreviation]).should == true
    page.has_content?(v[:rate].to_s).should == true
  end

  # Show links created in Organisation
  organisation.links.each do |l|
    page.has_content?(l.user.to_s).should == true
    page.has_content?(l.role).should == true
  end

end
