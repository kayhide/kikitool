Rails.application.routes.draw do
  root to: "dashboard#index"
  devise_for :users

  namespace :admin do
    root to: "users#index"
    resources :users
  end
end
