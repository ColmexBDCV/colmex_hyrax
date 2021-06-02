# Generated via
#  `rails generate hyrax:work Photography`
module Hyrax
  # Generated controller for Photography
  class PhotographiesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Photography

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PhotographyPresenter
  end
end
