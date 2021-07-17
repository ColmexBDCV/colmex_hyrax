# Generated via
#  `rails generate hyrax:work Recomendation`
module Hyrax
  # Generated controller for Recomendation
  class RecomendationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Recomendation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::RecomendationPresenter
  end
end
