Bonsaierp::Application.routes.draw do

  resources :stocks

  resources :account_types

  resources :inventory_operations do
    member do
      get :select_store
    end

    get :transactions, :on => :collection
    get :new_transaction, :on => :collection
    post :create_transaction, :on => :collection
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

  resources :payments 

  resources :pay_plans

  resources :projects

  resources :transactions

  ############################
  # IN/OUT
  ############################
  resources :incomes do
    member do
      put 'approve'
      put 'approve_credit'
      put 'approve_deliver'
    end
  end

  resources :buys do
    member do
      put 'approve'
      put 'approve_credit'
    end
  end

  resources :expenses do
    member do
      put 'approve'
    end
  end

  get  "/transactions/pdf/:id"       => "transactions#pdf", :as => :invoice_pdf
  get  "/transactions/new_email/:id" => "transactions#new_email", :as => :new_invoice_email
  post "/transactions/email/:id"     => "transactions#email"

  ###########################3

  resources :stores

  resources :contacts

  resources :clients

  resources :suppliers

  resources :staffs

  resources :items
  #match ':controller/new/:ctype' => 'items#new'

  resources :units

  resources :currencies

  #resources :links

  resources :taxes

  resources :organisations do
    get :check_schema,  :on => :member
    get :create_tenant, :on => :member
    get :select,        :on => :member
    get :create_data,   :on => :member

    get  :edit_preferences,   :on => :member
    put  :update_preferences, :on => :member
  end

  resources :countries

  resources :registrations
  get "/users/sign_up" => "registrations#new"

  # Password
  resources :reset_passwords

  # Sessions
  resources :sessions

  get "/users/sign_in"  => "sessions#new"
  get "/users/sign_out" => "sessions#destroy"

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

  #resources :dashboard
    
  match '/dashboard' => 'dashboard#index', :as => :dashboard
  match '/configuration' => 'dashboard#configuration'

  # Resque
  mount Resque::Server, :at => "/resque"  

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

  get "/tour" => 'home#index', :page => "tour"
  get "/prices" => 'home#index', :page => "prices"
  get "/team" => 'home#index', :page => "team"
  get "/contact" => 'home#index', :page => "contact"

  root :to => 'home#index'
end
