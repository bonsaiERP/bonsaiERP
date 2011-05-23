Bonsaierp::Application.routes.draw do

  resources :inventory_operations do
    member do
      get :select_store
    end

    get :transactions, :on => :collection
    get :new_sale, :on => :collection
    post :create_sale, :on => :collection
  end

  resources :account_ledgers do
    member do
      put  :conciliate
      put  :personal
      get  :new_transference
      post :transference
    end
  end
  # put 'account_ledgers/conciliate/:id' => 'account_ledgers#conciliate', :as => :conciliate

  resources :banks

  resources :cash_registers

  resources :payments 

  resources :pay_plans do
    member do
      post :email
    end
  end

  resources :currency_rates

  resources :projects

  resources :transactions

  ############################
  # IN/OUT
  ############################
  resources :incomes do
    member do
      put 'approve'
    end
  end

  resources :buys do
    member do
      put 'approve'
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
    get  :select,     :on => :member
    post :final_step, :on => :collection

    get  :edit_preferences,   :on => :member
    put  :update_preferences, :on => :member
  end

  resources :countries

  devise_for :users#, :path_names => { :sign_in => '/login', :sign_out => '/logout' }
  resources :users do
    collection do
      get  :add_user
      get  :password
      post :create_user
    end

    member do
      get :edit_user
      put :update_user
      put :update_password
    end
  end

  #resources :dashboard
    
  match '/dashboard' => 'dashboard#index', :as => :dashboard
  match '/configuration' => 'dashboard#configuration'

  # Rails Metal
  match "/client_autocomplete"   => AutocompleteApp.action(:client)
  match "/supplier_autocomplete" => AutocompleteApp.action(:supplier)
  match "/staff_autocomplete"    => AutocompleteApp.action(:staff)
  match "/item_autocomplete"     => AutocompleteApp.action(:item)

  root :to => 'home#index'
end
