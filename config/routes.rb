# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # a test only route used by spec/features/it_works_spec.rb
  get "test_root", to: "rails/welcome#index", as: "test_root_rails"

  authenticated :user do
    resources :profile, only: [:index, :show]
    get "/:id", to: "profile#show", as: :show_profile
    get "/", to: redirect("/profile")
  end

  get "/:id", to: "profile#show", as: :show_public_profile

  # Defines the root path route ("/")
  root to: "home#index"
end
