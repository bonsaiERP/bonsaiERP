namespace :api do
  namespace :v1 do

    resources :attachments, only: [:index, :show, :update] do
      get :count, on: :collection
    end

    resources :contacts, only: [:index, :create, :update] do
      get :count, on: :collection
    end

    resources :incomes, only: [:index, :show, :create, :update] do
      get :count, on: :collection
    end

    resources :items, only: [:index, :show] do
      get :count, on: :collection
    end

    resources :tags, only: [:index] do
      get :count, on: :collection
    end

    resources :tag_groups, only: [:index] do
      get :count, on: :collection
    end

  end
end
