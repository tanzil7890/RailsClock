RailsClocks::Engine.routes.draw do
  root to: 'dashboard#index'
  
  resources :requests, only: [:index, :show] do
    member do
      post :replay
      get :export
    end
    collection do
      get :performance
    end
  end

  namespace :api do
    resources :requests, only: [:index, :show] do
      member do
        post :replay
      end
      collection do
        get :performance
      end
    end
  end
end 