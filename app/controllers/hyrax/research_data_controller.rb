# Generated via
#  `rails generate hyrax:work ResearchData`
module Hyrax
  # Generated controller for ResearchData
  class ResearchDataController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::ResearchData

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ResearchDataPresenter
  end
end
