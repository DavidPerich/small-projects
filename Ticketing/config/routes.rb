Rails.application.routes.draw do
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'projects#index'

  get "/register", to: "users#new"


  get "/login", to: 'sessions#new'
  post "/login", to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'



  resources :projects
  resources :tickets do
    resources :comments, except: [:show, :new]
  end
  resources :tags, except: [:show]
end
