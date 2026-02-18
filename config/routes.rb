Rails.application.routes.draw do
  get "up" => "health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :links, only: [ :create ], param: :short_code do
        get :stats, on: :member
      end
    end
  end

  get "/:short_code", to: "redirects#show", constraints: { short_code: /[0-9A-Za-z]+/ }
end
