class SubjectCloudController < ApplicationController
  def index
    if params[:fields].present?
      @terms = get_terms
    end    # Construir el filtro para las plantillas registradas
    registered_types = Hyrax.config.registered_curation_concern_types
    model_filter = registered_types.map { |type| "has_model_ssim:\"#{type}\"" }.join(" OR ")
    publisher_filter = 'publisher_tesim:"El Colegio de México"'

    # Obtener el rango de años de los documentos activos SOLO de El Colegio de México
    years_query = ActiveFedora::SolrService.get(
      "(#{model_filter}) AND #{publisher_filter}", # Solo documentos de las plantillas registradas y publisher
      rows: 0,
      'facet': true,
      'facet.field': 'date_created_tesim',
      'facet.sort': 'index',
      'facet.limit': -1,
      'facet.mincount': 1 # Solo años que tengan al menos un documento
    )

    Rails.logger.debug "Plantillas registradas: #{registered_types.inspect}"
    Rails.logger.debug "Consulta Solr: #{years_query.inspect}"

    years = years_query['facet_counts']['facet_fields']['date_created_tesim'] || []

    # Convertir los años a números y filtrar valores no numéricos
    valid_years = []
    years.each_slice(2) do |year, count|
      # Solo incluir el año si es un número válido y tiene documentos
      if year.to_i.to_s == year && count > 0
        valid_years << year.to_i
      end
    end
    @min_year = valid_years.min || 1800
    @max_year = valid_years.max || Time.current.year
  end

  def get_terms
    # Obtener los campos seleccionados del parámetro
    fields = params[:fields] || []

    # Lista de términos a excluir (puedes personalizarla)
    exclusion_terms = [
      "méxico"
    ]

    # Obtener el rango de años
    start_year = params[:start_year]
    end_year = params[:end_year]

    # Construir el filtro para las plantillas registradas
    registered_types = Hyrax.config.registered_curation_concern_types
    solr_query = registered_types.map { |type| "has_model_ssim:\"#{type}\"" }.join(" OR ")

    # Construir la consulta Solr base con el filtro de plantillas y publisher

    solr_query = "(#{solr_query})"
    solr_query = "#{solr_query} AND has_model_ssim:\"Thesis\""

    # Agregar filtro de años si están presentes
    if start_year.present? && end_year.present?
      solr_query = "#{solr_query} AND date_created_tesim:[#{start_year} TO #{end_year}]"
    end

    # Inicializar el hash para almacenar términos y sus conteos
    terms = Hash.new(0)

    # Realizar la búsqueda en Solr para cada campo seleccionado
    fields.each do |field|
      field_name = field + "_tesim"
      start = 0
      page_size = 10000
      total = nil
      loop do
        results = ActiveFedora::SolrService.get(solr_query, rows: page_size, start: start, fl: "#{field_name}")
        docs = results["response"]["docs"]
        total ||= results["response"]["numFound"]

        docs.each do |doc|
          if doc[field_name].present?
            doc[field_name].each do |term|
              # Excluir términos de la lista
              next if exclusion_terms.include?(term.downcase.strip)
              # Guardar el campo al que pertenece el término
              terms[[term, field_name]] += 1
            end
          end
        end
        start += page_size
        break if start >= total || docs.empty?
      end
    end

    # Convertir el hash a formato compatible con jQCloud, incluyendo el campo tesim
    cloud_terms = terms.map do |(term, field_name), weight|
      { text: term, weight: weight, field: field_name }
    end

    # Ordenar los términos de mayor a menor peso
    cloud_terms.sort_by! { |t| -t[:weight] }

    # Aleatorizar los términos de peso bajo (<=2) para distribuirlos mejor
    # high_weight, low_weight = cloud_terms.partition { |t| t[:weight] > 2 }
    # low_weight.shuffle!
    # cloud_terms = high_weight + low_weight

    render json: cloud_terms.first(200) # Limitar a los 100 términos más frecuentes
  end
end
