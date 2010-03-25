Given /^the following countries:$/ do |countries|
  Country.create!(countries.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) country$/ do |pos|
  visit countries_url
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following countries:$/ do |expected_countries_table|
  expected_countries_table.diff!(tableish('table tr', 'td,th'))
end
