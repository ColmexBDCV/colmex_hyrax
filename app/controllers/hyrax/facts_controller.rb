# Generated via
#  `rails generate hyrax:work Fact`
module Hyrax
  # Generated controller for Fact
  class FactsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Fact

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::FactPresenter
  end
end
