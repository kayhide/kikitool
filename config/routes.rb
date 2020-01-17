Rails.application.routes.draw do
  get 'transcriptions/show'
  root to: "dashboard#index"
  devise_for :users

  namespace :api do
    resources :transcriptions, only: [:index, :show] do
      resources :segments, only: [:index], controller: "transcriptions/segments"
    end
  end

  namespace :admin do
    root to: "users#index"
    resources :users
    resources :transcriptions
    resources :vocabulary_filters
  end

  resources :audios
  resources :transcriptions, only: [:show]

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
