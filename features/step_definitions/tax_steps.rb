Given /^the following taxes:$/ do |taxes|
  Tax.create!(taxes.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) tax$/ do |pos|
  visit taxes_url
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following taxes:$/ do |expected_taxes_table|
  expected_taxes_table.diff!(tableish('table tr', 'td,th'))
end
