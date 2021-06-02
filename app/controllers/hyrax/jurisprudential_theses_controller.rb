# Generated via
#  `rails generate hyrax:work JurisprudentialThesis`
module Hyrax
  # Generated controller for JurisprudentialThesis
  class JurisprudentialThesesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::JurisprudentialThesis

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::JurisprudentialThesisPresenter
  end
end
