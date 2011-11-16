# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
Factory.define :org_country do |c|
  c.id 1
  c.name 'Boliva'
  c.abbreviation 'bo'
  c.taxes []
end

Factory.define :currency do |c|
  c.id 1
  c.name 'boliviano'
  c.symbol 'Bs.'
  c.code 'BOB'
end

Factory.define :user do |u|
  u.first_name "Boris" 
  u.last_name "Barroso"
  u.email "boris@example.com"
  u.phone "2755620"
  u.mobile "70681101"
  u.website "http://boliviaonrails.com"
  u.password "demo123"
  u.password_confirmation "demo123"
  u.description "Una descripción"
end

Factory.define :item do |it|
  it.name 'Pipocas'
  it.unit_id 1
  it.unitary_cost 1.5
  it.price 2
  it.code 'PIP101'
  it.discount '10:2 20:3 30:3.5'
end

Factory.define :contact do |c|
  c.name 'Karina Luna Pizarro'
  c.organisation_name "Casita"
  c.email 'venuska76@gmail.com'
  c.address "Mallasa\ncalle Nº4"
  c.phone '2745620'
  c.mobile '70113217'
  c.tax_number '3376951'
end
