# encoding: utf-8
Bonsaierp::Application.routes.draw do
  get '/download_pdf/:file/:name' => 'download#download_pdf', as: :download

  resources :taxes

  resources :tags do
    post :update_models, on: :collection
  end

  resources :inventories, only: [:index, :show] do
    get :show_movement, on: :member
    get :show_trans, on: :member
  end

  resources :inventory_transferences, only: [:new, :create, :show]

  resources :export_expenses, only: [:index, :create]

  resources :export_incomes, only: [:index, :create]

  resources :reports, only: [:index]

  resources :organisation_updates, only: [:edit, :update]

  resources :admin_users, except: [:index, :destroy]

  resources :configurations, only: [:index]

  resources :stocks, only: [:update]

  resources :account_ledgers do
    post :transference, on: :collection
    patch :conciliate, on: :member
  end

  resources :banks

  resources :cashes

  # Transference between accounts
  resources :transferences, only: [:new, :create]

  resources :devolutions, only: [] do
    member do
      get :new_income
      post :income
      get :new_expense
      post :expense
    end
  end

  resources :payments, only: [] do
    member do
      get :new_income
      post :income
      get :new_expense
      post :expense
    end
  end

  resources :projects

  ############################
  # IN/OUT
  ############################
  resources :incomes do
    member do
      patch :approve
      patch :null
      patch :inventory
      get :history
      get :ledgers
      get :inventories
    end
  end

  resources :incomes_inventory_ins, only: [:new, :create]
  resources :incomes_inventory_outs, only: [:new, :create]

  resources :expenses do
    member do
      patch :approve
      patch :null
      patch :inventory
      get :history
      get :ledgers
      get :inventories
    end
  end

  resources :expenses_inventory_ins, only: [:new, :create]
  resources :expenses_inventory_outs, only: [:new, :create]

  ###########################

  resources :stores do
    resources :inventory_ins, only: [:new, :create]
    resources :inventory_outs, only: [:new, :create]
  end

  resources :contacts do
    get :incomes, on: :member
    get :expenses, on: :member
  end

  resources :items do
    get :search_income, on: :collection
    get :search_expense, on: :collection
  end

  resources :units

  resources :organisations, only: [:new, :update]

  resources :user_passwords, only: [:new, :create] do
    collection do
      get :new_default
      post :create_default
    end
  end

  resources :users, only: [:show, :edit, :update]

  get '/dashboard' => 'dashboard#index', as: :dashboard
  get '/home' => 'dashboard#home', as: :home

  # No auth
  resources :registrations do
    # Checks the confirmation_token of users added by admin
    get :new_user, on: :member
  end

  get '/sign_up' => 'registrations#new'

  # No auth
  # Password
  resources :reset_passwords, only: [:index, :new, :create, :edit, :update]
  # No auth
  # Sessions
  resources :sessions, only: [:new, :create, :destroy]
  get '/sign_in'  => 'sessions#new', as: :login
  get '/sign_out' => 'sessions#destroy', as: :logout

  # Tests
  resources :tests
  get '/kitchen' => 'tests#kitchen' # Tests

  root to: 'sessions#new'
end
