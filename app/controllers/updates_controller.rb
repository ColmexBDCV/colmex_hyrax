class UpdatesController < ApplicationController
  with_themed_layout 'dashboard'
  before_action :authenticate_user!
  before_action :set_update, only: %i[show export_csv]

  include ImporterService

  # GET /updates or /updates.json
  def index
    @updates = Update.all
    @user = current_user
    @path = Rails.root
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    add_breadcrumb 'Actualizacion masiva', request.path
  end

  def validate
    sip = params[:sip].to_s
    return render json: { Error: "SIP no válido para actualizaciones" } unless sip.end_with?("_update")
    render :json => validate_csv_update(sip, params[:work], params[:repnal])
  end

  # GET /updates/1 or /updates/1.json
  def show
  end

  # GET /updates/new
  def new
    url = URI.parse('http://biblio-handle.colmex.mx:8080/handle/list')

    begin
      if Rails.env.production?
        response = Net::HTTP.get_response(url)
        code = response.code
      else
        code = "200"
      end

      if code == "200"
        @sips = list_sips.select { |s| s[:sip].end_with?("_update") }

        @user = current_user
        @path = Rails.root
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb 'Actualizacion masiva', request.path
        @update = Update.new
      else
        render 'handle_unavailable'
      end
    rescue => e
      render 'handle_unavailable', locals: { error: e.message }
    end
  end

  # POST /updates or /updates.json
  def create
    identifiers = params.dig("update", "identifiers") || []
    params["update"]["num_records"] = identifiers.count
    params["update"]["depositor"] = current_user.email
    params["update"]["status"] = "Procesando..."
    params["update"]["object_ids"] = params["update"]["identifiers"].to_json
    params["update"]["date"] = DateTime.now.utc.iso8601
    params["update"]["repnal"] = params["update"].key?("repnal") ? "Si" : "No"
    @update = Update.new(update_params)

    respond_to do |format|
      if @update.save
        format.html { redirect_to updates_url, notice: "El lote de actualizacion fue creado correctamente." }

        UpdateCreateJob.perform_later("digital_objects/#{params["update"]["name"]}/metadatos/metadatos.csv", params["update"]["object_type"], @update.id)

        format.json { render :show, status: :created, location: @update }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @update.errors, status: :unprocessable_entity }
      end
    end
  end

  def export_csv
    log_entries = JSON.parse(@update.changes_log || '[]')
    if log_entries.empty?
      log_entries = JSON.parse(@update.object_ids || '[]').map do |entry|
        {
          identifier: entry[0],
          status: entry[1],
          changes: nil
        }
      end
    end

    ExportCsvJob.perform_later(@update.name, @update.object_type, [], log_entries, @update.date&.to_s)

    redirect_to updates_path, notice: "La exportación del log a CSV ha comenzado. El archivo estará disponible en breve en la carpeta del SIP #{@update.name}."
  end

  private
    def set_update
      @update = Update.find(params[:id])
    end

    def update_params
      params.require(:update).permit(:name, :object_type, :depositor, :date, :storage_size, :status, :object_ids, :num_records, :repnal)
    end
end
