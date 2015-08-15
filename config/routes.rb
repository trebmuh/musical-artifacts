Rails.application.routes.draw do
  put '/settings', to: 'settings#update', as: 'settings'
  get '/settings', to: 'settings#edit', as: 'edit_settings'

  get '/comments_script', to: 'application#comments_script', as: 'comments_script'

  resources :apps, only: [:show, :index]

  root to: "artifacts#index"

  devise_for :users, ActiveAdmin::Devise.config.merge(:path => 'users')

  resources :artifacts
  get '/artifacts/:id/:filename', to: 'artifacts#download', as: :artifact_download

  get '/info/about', to: 'info#about', as: :info_about
  get '/info/contact', to: 'info#contact', as: :info_contact

  resources :searches, only: [] do
    collection do
      get :tags
      get :software
    end
  end

  ActiveAdmin.routes(self)
end
