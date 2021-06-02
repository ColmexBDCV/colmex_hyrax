# Generated via
#  `rails generate hyrax:work CriminalFact`
module Hyrax
  # Generated controller for CriminalFact
  class CriminalFactsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::CriminalFact

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::CriminalFactPresenter
  end
end
