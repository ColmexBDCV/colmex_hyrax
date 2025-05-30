# frozen_string_literal: true

class DerivativesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource class: ::FileSet

  def create
    file_set = ::FileSet.find(params[:file_set_id])
    if file_set.present?
      CreateDerivativesJob.perform_later(file_set, file_set.files.first.id)
      redirect_to [main_app, file_set.parent], notice: "Se ha iniciado la regeneración de derivados para #{file_set.title.first}"
    else
      redirect_to [main_app, file_set.parent], alert: "No se pudo encontrar el FileSet"
    end
  end
end
