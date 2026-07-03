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
      values = []

      Hyrax::config.registered_curation_concern_types.each do |wt|
        wt.singularize.classify.constantize.all.each do |row|
          values.concat(Array(row.try(:thematic_collection)))
        end
      end

      values.compact.map(&:to_s).map(&:strip).reject(&:blank?).uniq.sort
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
