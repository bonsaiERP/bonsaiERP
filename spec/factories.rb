# encoding: utf-8
Factory.define :client do |f|
  f.matchcode "Juan Perez"
  f.first_name "Juan"
  f.last_name "Perez"
  f.organisation_name "Perez"
end

Factory.define :supplier do |f|
  f.matchcode "Juan León"
  f.first_name "Juan"
  f.last_name "León"
  f.organisation_name "León"
end

Factory.define :bank do |f|
  f.name "Bank"
  f.number "123"
  f.currency_id 1
  f.amount 100
end

Factory.define :cash do |f|
  f.name "Cash"
  f.number "123"
  f.currency_id 1
  f.amount 100
end

Factory.define :project do |p|
  p.name "Project 1"
  p.date_start Date.today
  p.date_end Date.today + 30.days
end
