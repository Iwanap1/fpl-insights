Rails.application.routes.draw do
  get 'fixtures/index'
  devise_for :users
  root to: "pages#home"
  resources :players, only: [:index, :show]
  resources :fixtures, only: [:index]
  resources :users, only: [:show]
end
