class Dashboard::ExportsController < ApplicationController
  with_themed_layout 'dashboard'

  before_action :authenticate_user!
  before_action :require_admin!

  def index
    add_dashboard_breadcrumbs('Exportar datos')
    @export_path = Rails.root.join('digital_objects', 'exports')
    @files = Dir.glob(File.join(@export_path, '*.csv')).sort.reverse.map { |f| File.basename(f) }
    @collections = collection_titles
    @thematic_collections = thematic_collection_values
  end

  def create
    export_type = params[:export_type]

    case export_type
    when 'by_work_type'
      ExportByWorkTypeJob.perform_later(params[:work_type], params[:fields])
    when 'by_collection'
      ExportByCollectionJob.perform_later(params[:collection], params[:fields])
    when 'by_field'
      ExportByFieldJob.perform_later(params[:value], params[:key], params[:fields])
    when 'by_thematic_collection'
      thematic = params[:thematic_collection].presence || params[:collection]
      ExportByThematicCollectionJob.perform_later(thematic, params[:fields])
    when 'all'
      ExportAllJob.perform_later(params[:fields])
    else
      redirect_to dashboard_exports_path, alert: 'Tipo de exportación inválido' and return
    end

    redirect_to dashboard_exports_path, notice: 'La exportación ha sido encolada. El CSV se guardará en digital_objects/exports cuando termine.'
  end

  private

    def collection_titles
      Collection.all.each_with_object([]) do |collection, acc|
        acc.concat(Array(collection.try(:title)))
      end.compact.map(&:to_s).map(&:strip).reject(&:blank?).uniq.sort
    end

    def thematic_collection_values
      # Intentar usar RSolr hacia la URL configurada en config/solr.yml
      # Preferir campos no-analizados (ssim/ssi) para obtener valores completos
      candidates = %w[thematic_collection_sim]

      solr_url = begin
      byebug
        cfg = Rails.application.config_for(:solr) rescue nil
        cfg && cfg['url'] || ENV['SOLR_URL'] || 'http://127.0.0.1:8983/solr/hydra-indexer'
      end

      client = nil
      begin
        client = RSolr.connect(url: solr_url)
      rescue StandardError
        client = nil
      end

      # Primero intentar handler /terms vía RSolr
      if client
        field = candidates.find do |f|
          begin
            resp = client.get('terms', params: { 'terms.fl' => f, 'terms.limit' => 1 })
            resp['terms'] && resp['terms'][f].present?
          rescue StandardError
            false
          end
        end

        if field
          begin
            resp = client.get('terms', params: { 'terms.fl' => field, 'terms.limit' => -1 })
            raw = resp.dig('terms', field) || []
            values = raw.each_slice(2).map(&:first)
            return values.map(&:to_s).map(&:strip).reject(&:blank?).uniq.sort
          rescue StandardError
            # continuar al fallback
          end
        end
      end

      # Fallback: usar ActiveFedora faceting via select
      candidates.each do |field|
        begin
          resp = ActiveFedora::SolrService.get('*:*', rows: 0, facet: true, 'facet.field' => field, 'facet.limit' => -1)
          arr = resp.dig('facet_counts', 'facet_fields', field) || []
          next if arr.empty?
          values = arr.each_slice(2).map(&:first)
          return values.map(&:to_s).map(&:strip).reject(&:blank?).uniq.sort
        rescue StandardError
          next
        end
      end

      []
    end

    def require_admin!
      raise Hydra::AccessDenied unless current_user.admin?
    end

    def add_dashboard_breadcrumbs(current_label)
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb current_label, request.path
    end
end
