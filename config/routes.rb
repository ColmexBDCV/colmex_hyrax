require 'sidekiq/web'

Rails.application.routes.draw do
  post '/imports/validate', to: 'imports#validate'
  resources :imports, only: [:new,:index,:create,:update] do
    member do
      post 'export_csv'
    end
  end
  # get '/imports', to: 'imports#index'
  # get '/imports/new', to: 'imports#new'
  # post '/imports', to: 'imports#create'
  # get '/imports/:id', to: 'imports#show'
  # get '/imports/:id/edit', to: 'imports#edit'
  # patch '/imports/:id', to: 'imports#update'
  # delete '/imports/:id', to: 'imports#destroy'
  mount BrowseEverything::Engine => '/browse'
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  concern :oai_provider, BlacklightOaiProvider::Routes.new

  post '/derivatives/:file_set_id', to: 'derivatives#create', as: :create_derivatives

  get 'get_media', to: 'all_media#get_media'
  get 'all_coordinates', to: 'all_coordinates#fetch_docs'

  #Conacyt Requirements
  get 'persona_name', to: 'authority#person'


  get 'padron', to: 'conacyt_stats#padron'
  get 'ranking/articulos', to: 'conacyt_stats#articulos'
  get 'ranking/autores', to: 'conacyt_stats#autores'
  get 'descargas', to: 'conacyt_stats#descargas'

  #End Conacyt Requirements



  mount Sidekiq::Web => '/jobs'

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'


  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    # concerns :oai_provider


    concerns :searchable
    concerns :range_searchable

  end

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'

  # Rutas para la nube de subjects
  get '/subject_cloud', to: 'subject_cloud#index'
  get '/subject_cloud/get_terms', to: 'subject_cloud#get_terms'

  # Ruta para el mapa de línea de tiempo
  get '/timeline_map', to: 'timeline_map#show'

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
