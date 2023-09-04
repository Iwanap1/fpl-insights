Rails.application.routes.draw do
  get 'fixtures/index'
  devise_for :users
  root to: "pages#home"
  get 'test', to: "pages#test"
  get 'league_graph', to: "pages#league_graph"
  get 'user_dash', to: "pages#user_dash"
  resources :players, only: [:index, :show]
  resources :fixtures, only: [:index]
  resources :users, only: [:show]
end
