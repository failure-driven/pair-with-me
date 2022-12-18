# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  namespace :admin do
    resources :pairs
    resources :users
    resources :promotions do
      post :demo_send
    end

    root to: "pairs#index"
  end

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => "/admin/sidekiq"
  end

  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}

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
