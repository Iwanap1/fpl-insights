Rails.application.routes.draw do
  get 'fixtures/index'
  devise_for :users
  root to: "pages#home"
  get 'test', to: "pages#test"
  get 'league_graph', to: "pages#league_graph"
  resources :players, only: [:index, :show]
  resources :fixtures, only: [:index]
  resources :users, only: [:show]
end
