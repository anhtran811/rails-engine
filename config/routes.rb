Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :merchants, only: [:index, :show] do
        resources :items, only: [:index], controller: 'merchants/items'
      end
      resources :items do
        resource :merchant, only: [:show], controller: 'merchants'
      end
    end
  end
end
