Rails.application.routes.draw do
  get 'transcriptions/show'
  root to: "dashboard#index"
  devise_for :users

  namespace :admin do
    root to: "users#index"
    resources :users
    resources :transcriptions
  end

  resources :audios
  resources :transcriptions, only: [:show]

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
