# encoding:utf-8
# Used to create sample data
=begin
user = User.new_user('demo@example.com', 'demo123')
user.save!

user.confirm_token(user.confirmation_token)

UserSession.current_user = user

# Countries
YAML.load_file('db/defaults/countries.yml').each do |c|
  OrgCountry.create!(c){|co| co.id = c['id'] }
end
puts "Countries have been created."
# Currencies
YAML.load_file('db/defaults/currencies.yml').each do |c|
  Currency.create!(c) {|cu| cu.id = c['id'] }
end
puts "Currencies have been created."

org = Organisation.create!(:name => 'Bonsailabs', :country_id => 1, :currency_id => 1, :phone => 2745620, :mobile => '70681101', :address => "Mallasa calle 4 Nº 71\n (La Paz - Bolivia)")

puts "The organisation #{org.name} has been created"
=end
