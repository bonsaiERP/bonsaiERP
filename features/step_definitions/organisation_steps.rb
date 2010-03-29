Given /^I create and go to the login page$/ do
  @user = DataSupport::create_user
  visit "#{page}?confirmation_token=#{@user.confirmation_token}"
end

Then /^I fill data with (\w+), (\d+), (\w+), (\w+)$/ do |name, country_id, address, phone|
  fill_in "organisation_name" :with => name
  fill_in "organisation_country_id" :with => country_id
  fill_in "organisation_address" :with => address
  fill_in "organisation_phone" :with => phone
end
