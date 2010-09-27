# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
Factory.define :country do |c|
  c.name 'Boliva'
  c.abbreviation 'bo'
  c.taxes []
end

Factory.define :currency do |c|
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

