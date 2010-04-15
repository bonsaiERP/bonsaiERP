# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#
@user = User.create(:email => "boris@example.com", :password => "demo123", :password_confirmation => "demo123")

User.confirm_by_token(@user.confirmation_token)

taxes = [{:name => "Impuesto al Valor Agregado", :rate => 13, :abbreviation => "IVA"}, {:name => "Impuesto a las transacciones", :rate => 1.5, :abbreviation => "IT"}]
Country.create(:name => 'Bolivia', :abbreviation => 'bo', :taxes => taxes)

#Currency.create(:name => "boliviano", :symbol => "Bs.")
#Currency.create(:name => "dolar", :symbol => "$")
#Currency.create(:name => "euro", :symbol => "€")


