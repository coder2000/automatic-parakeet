Rails.application.routes.draw do
  # Locale switching route (outside of locale scope)
  patch "/locale/:locale", to: "locales#update", as: :set_locale

  scope "(:locale)", locale: /en|es/, defaults: {locale: :en} do
    get "home/index"
    ActiveAdmin.routes(self)
    devise_for :users

    # Games routes
    resources :games do
      # Followings routes nested under games
      resources :followings, only: [:create, :destroy]
      # Ratings routes nested under games
      resources :ratings, only: [:create, :update, :destroy], shallow: true
      # Comments routes nested under games
      resources :comments, except: [:index, :show], shallow: true
      # Download links routes
      resources :download_links, only: [] do
        member do
          get :download
        end
      end
    end

    # Users routes
    resources :users, only: [:show, :edit, :update] do
      member do
        get :games
      end
    end

    # Charts routes
    get "charts", to: "charts#index"
    # Most Downloaded routes
    get "downloaded", to: "downloaded#index"

    # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
    # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
    # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

    # Defines the root path route ("/")
    root "home#index"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", :as => :rails_health_check
end
