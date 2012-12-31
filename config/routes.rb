Bonsaierp::Application.routes.draw do

  resources :account_balances

  resources :stocks

  resources :account_types

  resources :inventory_operations do
    member do
      get :select_store
    end

    collection do
      # Transactions (Buy, Income)
      get :transactions
      get :new_transaction
      post :create_transaction
      # Transference
      get  :new_transference
      post :create_transference
    end
  end

  resources :accounts

  resources :account_ledgers do
    collection do
      get  :new_devolution
      post :devolution
    end
    get  :new_transference, :on => :collection
    post :transference,     :on => :collection
    member do
      put  :conciliate
      put  :personal
    end
  end
  # put 'account_ledgers/conciliate/:id' => 'account_ledgers#conciliate', :as => :conciliate

  resources :banks

  resources :cashes

  resources :payments, only: [:new, :create]

  resources :projects

  resources :transactions

  ############################
  # IN/OUT
  ############################
  resources :incomes do
    member do
      put :approve
      get :history
    end
    post :quick_income, on: :collection
  end

  resources :expenses do
    member do
      put :approve
      get :history
    end
    post :quick_expense, on: :collection
  end

  get  "/transactions/pdf/:id"       => "transactions#pdf", :as => :invoice_pdf
  get  "/transactions/new_email/:id" => "transactions#new_email", :as => :new_invoice_email
  post "/transactions/email/:id"     => "transactions#email"

  ###########################3

  resources :stores

  resources :contacts do
    get :search, on: :collection
  end

  resources :clients

  resources :suppliers

  resources :staffs

  resources :items do
    get :search, on: :collection
  end

  resources :units

  #resources :currencies

  resources :organisations do
    get :check_schema,  :on => :member
    get :create_tenant, :on => :member
    get :select,        :on => :member
    get :create_data,   :on => :member

    get  :edit_preferences,   :on => :member
    put  :update_preferences, :on => :member
  end

  #resources :countries

  resources :registrations
  get "/users/sign_up" => "registrations#new"

  # Password
  resources :reset_passwords

  # Sessions
  resources :sessions

  get "/users/sign_in"  => "sessions#new", :as => :login
  get "/users/sign_out" => "sessions#destroy", :as => :logout

  resources :users do
    collection do
      get  :add_user
      get  :password
      get  :default_password
      post :create_user
    end

    member do
      get :edit_user
      put :update_user
      put :update_password
      put :update_default_password
    end
  end

  match '/dashboard' => 'dashboard#index', :as => :dashboard
  match '/configuration' => 'dashboard#configuration'

  # Rails Metal
  match "/client_autocomplete"   => AutocompleteApp.action(:client)
  match "/supplier_autocomplete" => AutocompleteApp.action(:supplier)
  match "/staff_autocomplete"    => AutocompleteApp.action(:staff)
  match "/item_autocomplete"     => AutocompleteApp.action(:item)

  match "/client_account_autocomplete"   => AutocompleteApp.action(:client_account)
  match "/supplier_account_autocomplete" => AutocompleteApp.action(:supplier_account)
  match "/staff_account_autocomplete"    => AutocompleteApp.action(:staff_account)
  match "/item_account_autocomplete"     => AutocompleteApp.action(:item_account)
  match "/exchange_rates" => AutocompleteApp.action(:get_rates)
  match "/items_stock" => AutocompleteApp.action(:items_stock)

  root :to => 'sessions#new'
end
