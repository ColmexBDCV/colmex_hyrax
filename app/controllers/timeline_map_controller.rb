class TimelineMapController < ApplicationController
  def index
    # Obtener rango de años disponibles en Solr
    years_query = ActiveFedora::SolrService.get(
      'based_near_coordinates_tesim:[* TO *] AND date_created_tesim:[* TO *] AND thematic_collection_tesim:"Producción Institucional"',
      rows: 0,
      'facet': true,
      'facet.field': 'date_created_tesim',
      'facet.sort': 'index',
      'facet.limit': -1,
      'facet.mincount': 1
    )

    years = years_query['facet_counts']['facet_fields']['date_created_tesim'] || []

    valid_years = []
    years.each_slice(2) do |year, count|
      if year.to_i.to_s == year && count > 0
        valid_years << year.to_i
      end
    end

    @min_year = valid_years.min || 1800
    @max_year = valid_years.max || Time.current.year
  end

  def get_data
    start_year = params[:start_year] || '*'
    end_year   = params[:end_year]   || '*'

    solr_query = "date_created_tesim:[#{start_year} TO #{end_year}] AND based_near_coordinates_tesim:[* TO *] AND thematic_collection_tesim:\"Producción Institucional\""

    solr_response = ActiveFedora::SolrService.get(
      solr_query,
      rows: 10000,
      fl: 'id,title_tesim,date_created_tesim,based_near_coordinates_tesim, has_model_ssim, based_near_label_tesim'
    )

    docs = solr_response['response']['docs']

    data = []
    docs.each do |doc|
      coords = doc['based_near_coordinates_tesim']
      places = doc['based_near_label_tesim'] || []
      date   = doc['date_created_tesim']&.first
      title  = doc['title_tesim']&.first
      model  = doc['has_model_ssim']&.first

      if coords.present? && date.present? && title.present?
        coords.each_with_index do |coord, i|
          lat, lon = coord.split('|').map(&:to_f)
          if (lat != 0.0 && lon != 0.0) && !(lat.nil? && lon.nil?)
            data << {
              id: doc['id'],
              title: coords.length > 1 ? "#{title} (Ubicación #{i + 1})" : title, 
              date: date,
              model: model.pluralize.downcase,
              lat: lat,
              lon: lon,
              place: places[i].nil? ? "N/A" : places[i].gsub(', , ', ', ').delete_suffix(',').delete_suffix(', ') # si existe, agregamos la etiqueta del lugar
            }
          end
        end
      end
    end

    render json: data
  end
end
