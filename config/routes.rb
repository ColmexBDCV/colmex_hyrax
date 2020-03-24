Rails.application.routes.draw do
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  concern :oai_provider, BlacklightOaiProvider::Routes.new

   #Conacyt Requirements

   get 'padron', to: 'conacyt_stats#padron'
   get 'ranking/articulos', to: 'conacyt_stats#articulos'
   get 'ranking/autores', to: 'conacyt_stats#autores'
   get 'descargas', to: 'conacyt_stats#descargas'

   get 'oai/conacyt' => redirect( path: '/catalog/oai?verb=ListRecords&metadataPrefix=oai_dc&set=collection:Conacyt') 
  
   #End Conacyt Requirements
     
  require 'sidekiq/web'
  
  mount Sidekiq::Web => '/jobs'

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider

  
    concerns :searchable
    concerns :range_searchable

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

  mount PdfjsViewer::Rails::Engine => "/pdfjs", as: 'pdfjs'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
