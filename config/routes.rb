Rails.application.routes.draw do
  # Admin interface for managing dynamic links
  root "dynamic_links#index"

  resources :dynamic_links do
    member do
      get :analytics
      patch :toggle_active
    end
  end



  # Smart redirect endpoint - this handles the actual link redirects
  # Must be last to catch all remaining routes
  get ":short_code", to: "links#redirect", constraints: { short_code: /[a-zA-Z0-9_-]+/ }

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
