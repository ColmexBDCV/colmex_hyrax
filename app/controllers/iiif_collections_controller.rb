# frozen_string_literal: true

class IiifCollectionsController < ApplicationController
  def index
    headers['Access-Control-Allow-Origin'] = '*'

    render json: IiifManifestCollectionService.new(
      request: request,
      ability: current_ability,
      thematic_collection: params[:thematic_collection]
    ).build
  end
end
