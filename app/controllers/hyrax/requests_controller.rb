# Generated via
#  `rails generate hyrax:work Request`
module Hyrax
  # Generated controller for Request
  class RequestsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Request

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::RequestPresenter
  end
end
