# Generated via
#  `rails generate hyrax:work ArchivalDocument`
module Hyrax
  # Generated controller for ArchivalDocument
  class ArchivalDocumentsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::ArchivalDocument

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ArchivalDocumentPresenter
  end
end
