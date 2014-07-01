namespace :api do
  namespace :v1 do
    resources :items, only: [:index] do
      get :count, on: :collection
    end

    resources :tags, only: [:index] do
      get :count, on: :collection
    end

    resources :contacts, only: [:index, :create, :update] do
      get :count, on: :collection
    end

    resources :incomes, only: [:index, :create, :update] do
      get :count, on: :collection
    end
  end
end
