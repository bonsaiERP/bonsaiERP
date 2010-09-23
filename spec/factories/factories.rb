# encoding:utf-8
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

#user_factory = {:firs_name => "Boris Barroso", 
#  :email => 'admin@example.com', 
#  :password => "",
#  :password_confirmation => ""
#}
