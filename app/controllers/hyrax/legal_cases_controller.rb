# Generated via
#  `rails generate hyrax:work LegalCase`
module Hyrax
  # Generated controller for LegalCase
  class LegalCasesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::LegalCase

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::LegalCasePresenter
  end
end
