# Generated via
#  `rails generate hyrax:work Case`
module Hyrax
  # Generated controller for Case
  class CasesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Case

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::CasePresenter
  end
end
