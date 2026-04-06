Rails.application.routes.draw do
  resources :notifications, only: [:index] do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
    end
  end
  get "/.well-known/appspecific/com.chrome.devtools.json", to: proc { |env|
    [ 204, { "Content-Type" => "application/json" }, [] ]
  }

  devise_for :users
  resources :posts
  resources :users

  root "posts#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  require 'sidekiq/web'
  authenticate :user, ->(u) { u.admin? } do
    mount ExceptionTrack::Engine => "/exception-track"
    mount Sidekiq::Web => "/sidekiq"
  end
end
