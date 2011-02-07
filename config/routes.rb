Bonsaierp::Application.routes.draw do

  resources :banks

  resources :cash_registers

  resources :payments

  resources :pay_plans do
    member do
      get :email
    end
  end

  resources :currency_rates do
    member do
      get 'check'
    end
  end

  resources :projects

  resources :transactions

  resources :incomes do
    member do
      put 'aprove'
      put 'null'
    end
  end

  resources :buys

  resources :stores

  resources :contacts

  resources :items
  #match ':controller/new/:ctype' => 'items#new'

  resources :units

  resources :currencies

  resources :links

  resources :taxes

  resources :organisations do
    get :select, :on => :member
  end

  resources :countries

  devise_for :users#, :path_names => { :sign_in => '/login', :sign_out => '/logout' }
  resources :users

  match '/dashboard' => 'dashboard#index', :as => :dashboard

  root :to => 'organisations#index'
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
