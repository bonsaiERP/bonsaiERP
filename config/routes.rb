Bonsaierp::Application.routes.draw do

  resources :inventory_operations do
    member do
      get :select_store
    end

    get :transactions, :on => :collection
  end

  resources :account_ledgers do
    member do
      put  :conciliate
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

  resources :items
  #match ':controller/new/:ctype' => 'items#new'

  resources :units

  resources :currencies

  #resources :links

  resources :taxes

  resources :organisations do
    get  :select,     :on => :member
    post :final_step, :on => :collection
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

  root :to => 'home#index'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
