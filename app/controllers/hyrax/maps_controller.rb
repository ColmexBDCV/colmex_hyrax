# Generated via
#  `rails generate hyrax:work Map`
module Hyrax
  # Generated controller for Map
  class MapsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Map

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::MapPresenter
  end
end
