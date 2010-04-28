Then /I fill the contact form with ([A-Za-z\s]+), (\w+@\w+\.\w+), ([\w\s]+), (\d+), (\d+), (\w+)/ do |name, email, address, phone, mobile, tax_id|
  fill_in "contact[name]", :with => name
  fill_in "contact[email]", :with => email
  fill_in "contact[address]", :with => name
  fill_in "contact[phone]", :with => phone
  fill_in "contact[mobile]", :with => mobile

  click_button("Create")
end

And /I should see contact with ([A-Za-z\s]+), (\w+@\w+\.\w+), ([\w\s]+), (\d+), (\d+), (\w+)/ do |name, email, address, phone, mobile, tax_id|
  page.has_content? name
  page.has_content? email
  page.has_content? address
  page.has_content? phone
  page.has_content? mobile
  #Contact.all.size.should > 0
end

Then /I change the contact email with (\w+@\w+\.\w+)/ do |email|
  fill_in "contact[email]", email

  click_button("Update")
end

And /I should see contact email (\w+@\w+\.\w+)/ do |email|
  page.has_content? email
end
