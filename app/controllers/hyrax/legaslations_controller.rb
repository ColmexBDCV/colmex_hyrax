# Generated via
#  `rails generate hyrax:work Legaslation`
module Hyrax
  # Generated controller for Legaslation
  class LegaslationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Legaslation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::LegaslationPresenter
  end
end
