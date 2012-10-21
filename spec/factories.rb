# encoding: utf-8
FactoryGirl.define do
  factory :unit do
    name 'Kilogramo'
    symbol 'Kg.'
    visible true
  end

  factory :org_country do
    id 1
    name 'Boliva'
    code 'BO'
    abbreviation 'bo'
  end

  factory :currency do
    id 1
    name 'boliviano'
    symbol 'Bs.'
    code 'BOB'
  end

  factory :user do
    first_name "Boris" 
    last_name "Barroso"
    email "boris@example.com"
    phone "2755620"
    mobile "70681101"
    website "http://boliviaonrails.com"
    password "demo123"
    password_confirmation "demo123"
    description "Una descripción"
  end

  factory :organisation do
    name 'bonsaiERP'
    tenant 'bonsai'
    association :currency 
  end

  factory :contact do
    matchcode "Juan Perez"
    first_name "Juan"
    last_name "Perez"
    organisation_name "Perez"
  end

  factory :client do
    matchcode "Juan Perez"
    first_name "Juan"
    last_name "Perez"
    organisation_name "Perez"
  end

  factory :supplier do
    matchcode "Juan León"
    first_name "Juan"
    last_name "León"
    organisation_name "León"
  end

  factory :bank do
    name "Bank"
    number "123"
    currency_id 1
    amount 100
  end

  factory :cash do
    name "Cash"
    number "123"
    #currency_id 1
    amount 100
  end

  factory :project do
    name "Project 1"
    date_start Date.today
    date_end Date.today + 30.days
  end
end
