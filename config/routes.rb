Rails.application.routes.draw do
  resources :invoices
  resources :items
  resources :customers
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post '/inbox/callback', to: 'callbacks#inbox'
  post '/treasury/callback', to: 'callbacks#treasury_payment_callback'

  get 'test', to: 'callbacks#test'
end
