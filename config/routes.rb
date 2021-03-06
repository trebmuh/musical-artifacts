require 'resque/server'

Rails.application.routes.draw do
  mount Knock::Engine => "/api"

  constraints CanAccessResque do
    mount Resque::Server, at: 'resque'
  end

  put '/settings', to: 'settings#update', as: 'settings'
  get '/settings', to: 'settings#edit', as: 'edit_settings'

  get '/comments_script', to: 'application#comments_script', as: 'comments_script'

  resources :apps, only: [:show, :index]

  root to: "artifacts#index"

  devise_for :users, ActiveAdmin::Devise.config.merge(:path => 'users',
    controllers: {
      passwords: 'users/passwords', registrations: 'users/registrations',
      sessions: 'users/sessions', omniauth_callbacks: 'users/auth_callbacks'
    }
  )

  devise_scope :user do
    post '/users/auth/', as: 'create_with_omniauth', controller: 'users/auth_callbacks', action: 'create_with_omniauth'
  end

  get 'my_artifacts', to: 'users#show', as: :my_artifacts

  resources :activities, only: [:index], as: 'activities'

  resources :artifacts
  get '/artifacts/:id/*filename', to: 'artifacts#download', as: :artifact_download, format: false

  post '/artifacts/:artifact_id/favorite/', to: 'favorites#create', as: :favorite_artifact, defaults: { format: :json }
  delete '/artifacts/:artifact_id/favorite/', to: 'favorites#destroy', as: :unfavorite_artifact, defaults: { format: :json }

  get '/hydrogen_drumkits', to: 'hydrogen_drumkits#index', as: 'hydrogen_drumkits', defaults: { format: :xml }

  get '/info/about', to: 'info#about', as: :info_about
  get '/info/contact', to: 'info#contact', as: :info_contact
  get '/info/survey', to: 'info#survey', as: :info_survey
  get '/analytics_optout', to: 'info#optout', as: :analytics_optout
  get '/terms_and_conditions', to: 'info#terms_and_conditions', as: :terms_and_conditions

  post '/locale/:locale', to: 'locales#set_locale', as: :set_locale

  # For licenses api
  resources :licenses, only: [:index], defaults: { format: :json }

  resources :searches, only: [], defaults: { format: :json } do
    collection do
      get :tags
      get '/apps', action: :software
      get :file_formats
    end
  end

  post '/notifications/:notification_type/dismiss', to: 'notifications#dismiss', defaults: { format: :json }

  ActiveAdmin.routes(self)
end
