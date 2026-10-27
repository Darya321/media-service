Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#show"
  get "/about", to: "pages#about", as: :about
  get "/soon", to: "pages#soon", as: :soon

  resources :posts, path: "media", param: :slug, only: %i[index show]
  resources :categories, param: :slug, only: :show
  resources :materials, param: :slug, only: %i[index show]

  resource :calculator, only: :show, controller: "calculator" do
    post :estimate
  end

  resources :suppliers, param: :slug, only: %i[index show]
  resources :subscriptions, only: :create
  resources :inquiries, only: %i[new create]

  namespace :admin do
    root "dashboard#show"
    resource :session, only: %i[new create destroy]
    resources :categories
    resources :posts
    resources :materials
    resources :suppliers
    resources :subscriptions, only: :index
    resources :inquiries, only: %i[index show update]
  end
end
