# Generated via
#  `rails generate hyrax:work Judgment`
module Hyrax
  # Generated controller for Judgment
  class JudgmentsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Judgment

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::JudgmentPresenter
  end
end
