class ImportsController < ApplicationController
  with_themed_layout 'dashboard'
  before_action :authenticate_user!
  before_action :set_import, only: %i[ show edit update destroy ]

  include ImporterService

  # GET /imports or /imports.json
  def index
    @imports = Import.all
    @user = current_user
    @path = Rails.root
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    add_breadcrumb t(:'hyrax.admin.sidebar.imports'), request.path
  end
  
  def validate
    render :json => validate_csv(params[:sip], params[:work], params[:repnal])
  end

  # GET /imports/1 or /imports/1.json
  # def show
  # end

  # GET /imports/new
  def new
    # @qa = get_qa
    @sips = []
    imports = Import.where.not(status: "Cancelado").pluck(:name)
    list_sips.each { |s|  @sips.push s unless imports.include?(s[:sip]) }

    @user = current_user
    @path = Rails.root
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    add_breadcrumb t(:'hyrax.admin.sidebar.imports'), request.path
    @import = Import.new
  end

  # GET /imports/1/edit
  # def edit
  # end

  # POST /imports or /imports.json
  def create
    params["import"]["num_records"] = params["import"]["identifiers"].count
    params["import"]["depositor"] = current_user.email
    params["import"]["status"] = "Procesando..."
    params["import"]["object_ids"] = params["import"]["identifiers"].to_json
    params["import"]["date"] = DateTime.now.strftime("%d/%m/%Y %H:%M")
    params["import"]["repnal"] = params["import"].key?("repnal") ? "Si" : "No"
    @import = Import.new(import_params)
    
    respond_to do |format|
      if @import.save
        format.html { redirect_to import_url(@import), notice: "Import was successfully created." }

        ImportCreateJob.perform_later("digital_objects/#{params["import"]["name"]}/metadatos/metadatos.csv", params["import"]["object_type"], nil, @import.id )

        format.json { render :show, status: :created, location: @import }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /imports/1 or /imports/1.json
  def update
    params[:import][:status] = "Cancelando..."
    params["import"]["depositor"] = current_user.email
    respond_to do |format|
      if @import.update(import_params)
        ImportUndoJob.perform_later(params[:import][:id],params[:import][:object_type],params[:import][:object_ids])
        # format.html { redirect_to import_url(@import), notice: "Import was successfully updated." }
        format.html { redirect_to imports_url, notice: "Import was successfully destroyed." }
        format.json { render :show, status: :ok, location: @import }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /imports/1 or /imports/1.json
  # def destroy
  #   @import.destroy

  #   respond_to do |format|
  #     format.html { redirect_to imports_url, notice: "Import was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_import
      @import = Import.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def import_params
      params.require(:import).permit(:id, :name, :object_type, :depositor, :date, :storage_size, :status, :object_ids, :num_records, :repnal)
    end
end
