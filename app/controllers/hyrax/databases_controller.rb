# Generated via
#  `rails generate hyrax:work DataBase`
module Hyrax
  # Generated controller for DataBase
  class DatabasesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Database

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::DatabasePresenter
  end
end
