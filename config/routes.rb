# encoding: utf-8
Bonsaierp::Application.routes.draw do

  resources :inventory_operations, only: [:index, :show]

  resources :inventory_transferences, only: [:new, :create]

  resources :inventory_outs, only: [:new, :create]

  resources :inventory_ins, only: [:new, :create]

  resources :export_expenses, only: ['index', 'create']

  resources :export_incomes, only: ['index', 'create']

  resources :reports, only: ['index']

  resources :organisation_updates, only: [:edit, :update]

  resources :admin_users, except: [:index, :destroy]

  resources :configurations, only: ['index']

  resources :tests

  resources :stocks

  resources :account_ledgers do
    post :transference, on: :collection
    put :conciliate, on: :member
  end

  resources :banks

  resources :cashes

  # Transference between accounts
  resources :transferences, only: ['new', 'create']

  resources :devolutions, only: [] do
    member do
      post :income
      post :expense
    end
  end

  resources :payments, only: [] do
    member do
      post :income
      post :expense
    end
  end

  resources :projects

  ############################
  # IN/OUT
  ############################
  resources :incomes do
    member do
      put :approve
      put :null
      get :history
    end

    post :quick_income, on: :collection
  end

  resources :expenses do
    member do
      put :approve
      put :null
      get :history
    end
    post :quick_expense, on: :collection
  end

  #get  "/transactions/pdf/:id"       => "transactions#pdf", :as => :invoice_pdf
  #get  "/transactions/new_email/:id" => "transactions#new_email", :as => :new_invoice_email
  #post "/transactions/email/:id"     => "transactions#email"

  ###########################3

  resources :stores

  resources :contacts

  resources :staffs

  resources :items do
    get :search_income, on: :collection
    get :search_expense, on: :collection
  end

  resources :units

  resources :organisations, only: ['new', 'update']

  resources :user_passwords, only: ['new', 'create'] do
    collection do
      get :new_default
      post :create_default
    end
  end

  resources :users, only: ['show', 'edit', 'update']

  get '/dashboard' => 'dashboard#index', :as => :dashboard

  # No auth
  resources :registrations do
    get :new_user, on: :member # Checks the confirmation_token of users added by admin
  end
  get "/sign_up" => "registrations#new"

  # No auth
  # Password
  resources :reset_passwords, only: ['new', 'create', 'edit', 'update']
  # No auth
  # Sessions
  resources :sessions, only: ['new', 'create', 'destroy']
  get "/sign_in"  => "sessions#new", as: :login
  get "/sign_out" => "sessions#destroy", as: :logout

  root to: 'sessions#new'
end
