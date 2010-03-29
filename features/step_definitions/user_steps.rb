Given /^Iam on "([^\"]*)" page$/ do |page|
  visit page
end

And /^I insert data with (\w+), (\w+), (\w+@\w+\.\w+), (\w+)$/ do |first_name, last_name, email, password|
  fill_in "user_first_name", :with => first_name
  fill_in "user_last_name", :with => last_name
  fill_in "user[email]", :with => email
  fill_in "user_password", :with => password
  fill_in "user_password_confirmation", :with => password

  find_button("Create").click
end


And /I should see a page with (\w+)/ do |first_name|
  page.has_content?(first_name).should == true
end

Given /^I confirm my subcription in "([^\"]*)"$/ do |page|
  @user = User.last
  visit "#{page}?confirmation_token=#{@user.confirmation_token}"
end

And /^I see "([^\"]*)"$/ do |url|
  page.current_url.should == url
end

And /^Iam on "([^\"]*)"$/ do |page|
  visit page
end

Then /^fill login data with (\w+@\w+\.\w+), (\w+)$/ do |email, password|
  fill_in "user[email]", :with => email
  fill_in "user_password", :with => password

  find_button("Sign in").click
end

