Bonsaierp::Application.routes.draw do

  resources :admin_users, except: [:index, :destroy]

  resources :configurations, only: ['index']

  resources :tests

  resources :stocks

  resources :inventory_operations do
    member do
      get :select_store
    end

    collection do
      # Transactions (Income, Expense)
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

  resources :transactions

  ############################
  # IN/OUT
  ############################
  resources :incomes do
    member do
      put :approve
      get :history
      put :payment_date
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
    get :check_schema,  on: :member
    get :create_tenant, on: :member
    get :select,        on: :member
    get :create_data,   on: :member

    get  :edit_preferences,   on: :member
    put  :update_preferences, on: :member
  end

  #resources :countries

  resources :registrations do
    get :new_user, on: :member
  end

  get "/sign_up" => "registrations#new"

  # Password
  resources :reset_passwords

  # Sessions
  resources :sessions

  get "/sign_in"  => "sessions#new", as: :login
  get "/sign_out" => "sessions#destroy", as: :logout

  resources :users

  get '/dashboard' => 'dashboard#index', :as => :dashboard

  # Rails Metal
  #get "/client_autocomplete"   => AutocompleteApp.action(:client)
  #get "/supplier_autocomplete" => AutocompleteApp.action(:supplier)
  #get "/staff_autocomplete"    => AutocompleteApp.action(:staff)
  #get "/item_autocomplete"     => AutocompleteApp.action(:item)

  #get "/client_account_autocomplete"   => AutocompleteApp.action(:client_account)
  #get "/supplier_account_autocomplete" => AutocompleteApp.action(:supplier_account)
  #get "/staff_account_autocomplete"    => AutocompleteApp.action(:staff_account)
  #get "/item_account_autocomplete"     => AutocompleteApp.action(:item_account)
  #get "/exchange_rates" => AutocompleteApp.action(:get_rates)
  #get "/items_stock" => AutocompleteApp.action(:items_stock)

  root :to => 'sessions#new'
end
