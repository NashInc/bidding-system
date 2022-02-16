Rails.application.routes.draw do
  resources :customers
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post '/inbox/callback', to: 'callbacks#inbox'

  get "test", to: "callbacks#test"
end
