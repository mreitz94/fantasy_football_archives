Rails.application.routes.draw do
  resources :leagues, except: [:show] do
    resources :teams, only: [:index]

    member do
      get 'standings'
    end
  end

  devise_for :users

  root "leagues#index"
end
