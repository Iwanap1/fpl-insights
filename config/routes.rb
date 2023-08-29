Rails.application.routes.draw do
  get 'fixtures/index'
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :players, only: [:index, :show]
  resources :fixtures, only: [:index]
end
