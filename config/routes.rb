Rails.application.routes.draw do
  resources :auctions
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :invoices
  resources :items
  resources :customers
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "auctions#index"

  post '/inbox/callback', to: 'callbacks#inbox'
  post '/treasury/callback', to: 'callbacks#treasury_payment_callback'

  get 'test', to: 'callbacks#test'
end
