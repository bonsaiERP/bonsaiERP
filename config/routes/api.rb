namespace :api do
  namespace :v1 do
    resources :items, only: [:index]

    resources :tags, only: [:index]

    resources :contacts, only: [:index, :create, :update]
  end
end
