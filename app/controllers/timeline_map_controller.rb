# app/controllers/timeline_map_controller.rb
class TimelineMapController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::SearchContext
  include Blacklight::SearchHelper

  def show
    start_year = params[:start_year] || '*'
    end_year   = params[:end_year]   || '*'

    solr_query = "date_created_tesim:[#{start_year} TO #{end_year}] AND based_near_coordinates_tesim:[* TO *]"

    solr_response = ActiveFedora::SolrService.get(
      solr_query,
      rows: 5000,
      fl: 'id,title_tesim,date_created_tesim,based_near_coordinates_tesim'
    )

    @document_list = solr_response['response']['docs']

    @data = @document_list.map do |doc|
      coordinates = doc['based_near_coordinates_tesim']&.first
      date_created = doc['date_created_tesim']&.first
      title = doc['title_tesim']&.first

      if coordinates.present? && date_created.present? && title.present?
        lat, lon = coordinates.split('|').map(&:to_f)
        if lat != 0.0 && lon != 0.0
          {
            id: doc['id'],
            title: title,
            date: date_created,
            lat: lat,
            lon: lon
          }
        end
      end
    end.compact

    respond_to do |format|
      format.html # para la vista inicial
      format.json { render json: @data } # para peticiones dinámicas desde JS
    end
  end
end
