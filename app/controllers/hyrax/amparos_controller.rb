# Generated via
#  `rails generate hyrax:work Amparo`
module Hyrax
  # Generated controller for Amparo
  class AmparosController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Amparo

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::AmparoPresenter
  end
end
