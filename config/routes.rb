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

  resources :account_ledgers do
    post :transference, on: :collection
    put :conciliate, on: :member
  end

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

  #get  "/transactions/pdf/:id"       => "transactions#pdf", :as => :invoice_pdf
  #get  "/transactions/new_email/:id" => "transactions#new_email", :as => :new_invoice_email
  #post "/transactions/email/:id"     => "transactions#email"

  ###########################3

  resources :stores

  resources :contacts

  resources :staffs

  resources :items

  resources :units

  resources :organisations, only: ['new', 'update']

  resources :user_passwords, only: ['new', 'create'] do
    collection do
      get :new_default
      put :create_default
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
  resources :reset_passwords, only: ['show', 'new', 'create']
  # No auth
  # Sessions
  resources :sessions, only: ['new', 'create', 'destroy']
  get "/sign_in"  => "sessions#new", as: :login
  get "/sign_out" => "sessions#destroy", as: :logout

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
