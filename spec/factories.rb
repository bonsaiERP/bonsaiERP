# encoding: utf-8
FactoryGirl.define do

  factory :attachment do
    name 'picture.jpg'
    position 1
    attachable_id 1
    attachable_type 'Item'
  end

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
    password "demo1234"
    description "Una descripción"
  end

  factory :organisation do
    name 'bonsaiERP'
    tenant 'bonsai'
    currency 'BOB'
    country_code 'BO'
    inventory true
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
    currency 'BOB'
    name { "Cash #{currency}" }
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
    delivered false
  end

  factory :income do
    ref_number "I-0001"
    date { Date.today }
    due_date { 2.days.from_now }
    association :contact, factory: :contact, strategy: :build
    currency 'BOB'
    description "New income description"
    state "draft"
    balance 100
    total { balance }
    factory :income_approved do
      state "approved"
    end
  end

  factory :expense do
    ref_number "E-0001"
    date { Date.today }
    due_date { 2.days.from_now }
    association :contact, factory: :contact, strategy: :build
    currency 'BOB'
    description "New expense description"
    state "draft"
    balance 100
    total { balance }
    factory :expense_approved do
      state 'approved'
    end
  end

  factory :account_ledger do
    date Date.today
    operation "payin"
    status "approved"
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
    role User::ROLES[1]
    master_account true
    api_token { SecureRandom.urlsafe_base64(32) }
  end

  factory :store do
    name 'Store 1'
    phone '23232323'
    address 'Samaipata'
  end

  factory :stock do
    association :store, factory: :store, strategy: :build
    association :item, factory: :item, strategy: :build
    quantity 1
  end

  factory :inventory do
    date '2013-05-10'
    operation 'in'
  end

  factory :tax do
    name 'IVA'
    percentage 10
  end

  factory :tag do
    name 'first tag'
    bgcolor '#efefef'
  end

  factory :loan_give, class: Loans::Give do
    date Date.today
    due_date Date.today
  end

  factory :loan_receive, class: Loans::Receive do
    date Date.today
    due_date Date.today
  end

end
