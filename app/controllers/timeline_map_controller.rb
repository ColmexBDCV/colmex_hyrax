# app/controllers/timeline_map_controller.rb
class TimelineMapController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::SearchContext
  include Blacklight::SearchHelper

  def show
    # Build a Solr query using ActiveFedora::SolrService
    solr_response = ActiveFedora::SolrService.get(
      'date_created_tesim:[* TO *] AND based_near_coordinates_tesim:[* TO *]',
      rows: 100000,
      fl: 'id,title_tesim,date_created_tesim,based_near_coordinates_tesim'
    )

    # Get the documents from the response
    @document_list = solr_response['response']['docs']
    # Transform Solr documents into a format suitable for the map and timeline
    @data = @document_list.map do |doc|
      # Extract and validate required fields
      coordinates = doc['based_near_coordinates_tesim']&.first
      date_created = doc['date_created_tesim']&.first
      title = doc['title_tesim']&.first

      if coordinates.present? && date_created.present? && title.present?
        # Parse coordinates from "latitude|longitude" format
        lat, lon = coordinates.split('|').map(&:to_f)

        # Create the data structure only if we have valid coordinates
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
  end
end
