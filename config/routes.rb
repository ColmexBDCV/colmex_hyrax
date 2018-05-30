Rails.application.routes.draw do
  concern :oai_provider, BlacklightOaiProvider::Routes.new

   #Conacyt Requirements

   get 'padron', to: 'conacyt_stats#padron'
   get 'ranking/articulos', to: 'conacyt_stats#articulos'
   get 'ranking/autores', to: 'conacyt_stats#autores'
   get 'descargas', to: 'conacyt_stats#descargas'
 
   #End Conacyt Requirements
     
  require 'sidekiq/web'
  
  mount Sidekiq::Web => '/jobs'

  mount Blacklight::Engine => '/'
  
    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider

  
    concerns :searchable
  end

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'

  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resources :imports do
    member do
      post 'start'
      post 'undo'
      post 'resume'
      post 'finalize'
      get 'report'
      get 'image_preview/:row', controller: 'imports', action: :image_preview, as: 'image_preview'
      get 'row-preview/:row_num', controller: 'imports', action: :row_preview, as: 'row_preview'
    end
    collection do
      post 'browse'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
