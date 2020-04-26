Rails.application.routes.draw do
  # resources :users
  root to: 'posts#index'

  get "/register", to: "users#new"

  get "/login", to: 'sessions#new'
  post "/login", to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

  resources :posts, except: [:destroy] do
    member do
      post 'vote'
    end

    resources :comments, only: [:create] do
      post 'vote'
    end
  end

  resources :categories, only: [:show, :new, :create]
  resources :users, only: [:show, :create, :edit, :update]
end
