get '/download_pdf/:file/:name' => 'download#download_pdf', as: :download

#resources :movement_details_history, only: [:show]
get '/movement_details_history/:id' => 'movement_details_history#show', as: :movement_detail_history

# Batch payments
post 'batch_paymets/income' => 'batch_payments#income', as: :income_batch_payments

post 'batch_paymets/expense' => 'batch_payments#expense', as: :expense_batch_payments

resources :attachments, only: [:create, :update, :destroy]

resources :loan_payments, only: [] do
  member do
    # Receive
    get :new_pay
    post :pay
    get :new_pay_interest
    post :pay_interest
    # Give
    get :new_charge
    post :charge
    get :new_charge_interest
    post :charge_interest
  end
end

# Loans
resources :loans, only: [:index, :show, :update] do
  collection do
    get :new_receive
    post :receive
    get :new_give
    post :give
  end
end

# Loans ledger_in
get 'loan_ledger_ins/:id/new_give' => 'loan_ledger_ins#new_give', as: :new_give_loan_ledger_in
patch 'loan_ledger_ins/:id/give' => 'loan_ledger_ins#give', as: :give_loan_ledger_in
get 'loan_ledger_ins/:id/new_receive' => 'loan_ledger_ins#new_receive', as: :new_receive_loan_ledger_in
patch 'loan_ledger_ins/:id/receive' => 'loan_ledger_ins#receive', as: :receive_loan_ledger_in

resources :taxes

resources :tags do
  patch :update_models, on: :collection
end

resources :tag_groups

resources :inventories, only: [:index, :show] do
  get :show_movement, on: :member
  get :show_trans, on: :member
end

resources :inventory_transferences, only: [:new, :create, :show]

resources :export_expenses, only: [:index, :create]

resources :export_incomes, only: [:index, :create]

resources :reports, only: [:index]

get 'inventory_report' => 'reports#inventory', as: :inventory_report

resources :organisation_updates, only: [:edit, :update]

resources :admin_users, except: [:index] do
  patch :active, on: :member
end

resources :configurations, only: [:index]

resources :stocks, only: [:update]

resources :account_ledgers, only: [:index, :show, :update] do
  post :transference, on: :collection
  patch :conciliate, on: :member
  patch :null, on: :member
end

resources :banks do
  get :money, on: :collection
end

resources :cashes

resources :staff_accounts

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
  end
end

resources :incomes_inventory_ins, only: [:new, :create]
resources :incomes_inventory_outs, only: [:new, :create]

resources :expenses do
  member do
    patch :approve
    patch :null
    patch :inventory
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
  get :search_inventory, on: :member
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

get '/404', to: 'errors#page_not_found'
get '/422', to: 'errors#unacceptable'
get '/500', to: 'errors#internal_error'
