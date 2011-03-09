# encoding:utf-8
# Used to create sample data
user = User.create(:email => "demo@example.com", :password => "demo123", :password_confirmation => "demo123", :first_name => "Demo", :last_name => "Super Demo")

User.confirm_by_token(user.confirmation_token)

UserSession.current_user = user

# Countries
YAML.load_file('config/defaults/countries.yml').each do |c|
  Country.create!(c){|co| co.id = c['id'] }
end
puts "Countries have been created."
# Currencies
YAML.load_file('config/defaults/currencies.yml').each do |c|
  Currency.create!(c) {|cu| cu.id = c['id'] }
end
puts "Currencies have been created."

org = Organisation.create!(:name => 'Zenlabs', :country_id => 1, :currency_id => 1, :phone => 2745620, :mobile => '70681101', :address => "Mallasa calle 4 Nº 71\n (La Paz - Bolivia)")

puts "The organisation #{org.name} has been created"

b = Bank.create(:currency_id => 1, :name => 'Banco bancon', :number => '1111-7711', :total_amount => 10000)
puts "Bank #{b.name} #{b.number} was created"
