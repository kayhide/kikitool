Rails.application.routes.draw do
  root to: "dashboard#index"
  devise_for :users

  namespace :admin do
    root to: "users#index"
    resources :users
    resources :transcriptions
  end

  resources :audios

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
