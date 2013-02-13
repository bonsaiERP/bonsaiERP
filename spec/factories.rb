# encoding: utf-8
FactoryGirl.define do
  factory :unit do
    name 'Kilogramo'
    symbol 'Kg.'
    visible true
  end

  factory :org_country do
    name 'Boliva'
    code 'BO'
    abbreviation 'bo'
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
    currency 'BOB'
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
    currency 'BOB'
    amount 100
  end

  factory :cash do
    name "Cash"
    currency 'BOB'
    amount 100
  end

  factory :project do
    name "Project 1"
    date_start { Date.today }
    date_end { Date.today + 30.days }
  end

  factory :account do
    name "First account"
    amount 0
    currency 'BOB'
  end

  factory :transaction do
    total 100
  end

  factory :income do
    ref_number "I-0001"
    date { Date.today }
    association :contact, factory: :contact, strategy: :build
    currency 'BOB'
    description "New income description"
    state "draft"
    balance 100
    association :transaction, factory: :transaction, strategy: :build
  end

  factory :expense do
    ref_number "E-0001"
    date { Date.today }
    association :contact, factory: :contact, strategy: :build
    currency 'BOB'
    description "New expense description"
    state "draft"
    balance 100
    association :transaction, factory: :transaction, strategy: :build
  end

  factory :account_ledger do
    date Date.today
    operation "payin"
    reference "Income"
    amount 100
    exchange_rate 1
    inverse false
    account_id 1
    account_to_id 2
  end

  factory :item do
    name 'The first item'
    code 'P000-1'
    active true
    stockable true
    for_sale true
    price 10
  end

  factory :link do
    rol User::ROLES[1]
    master_account true
  end
end
