Given /^the following organisations:$/ do |organisations|
  Organisation.create!(organisations.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) organisation$/ do |pos|
  visit organisations_url
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following organisations:$/ do |expected_organisations_table|
  expected_organisations_table.diff!(tableish('table tr', 'td,th'))
end
