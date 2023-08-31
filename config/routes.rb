Rails.application.routes.draw do
  get 'fixtures/index'
  devise_for :users
  root to: "pages#home"
  get 'test', to: "pages#test"
  resources :players, only: [:index, :show]
  resources :fixtures, only: [:index]
  resources :users, only: [:show]
end
