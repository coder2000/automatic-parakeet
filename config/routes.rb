Rails.application.routes.draw do
  scope "(:locale)", locale: /en|es/ do
    get "home/index"
    ActiveAdmin.routes(self)
    devise_for :users

    # Games routes
    resources :games do
      # Followings routes nested under games
      resources :followings, only: [:create, :destroy]
    end
    
    # Charts routes
    get 'charts', to: 'charts#index'

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    get "up" => "rails/health#show", :as => :rails_health_check

    # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
    # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
    # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

    # Defines the root path route ("/")
    root "home#index"
  end
end
