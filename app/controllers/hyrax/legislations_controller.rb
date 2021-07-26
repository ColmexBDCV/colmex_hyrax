# Generated via
#  `rails generate hyrax:work Legislation`
module Hyrax
  # Generated controller for Legislation
  class LegislationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Legislation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::LegislationPresenter
  end
end
