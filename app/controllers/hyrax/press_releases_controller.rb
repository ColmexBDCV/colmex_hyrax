# Generated via
#  `rails generate hyrax:work PressRelease`
module Hyrax
  # Generated controller for PressRelease
  class PressReleasesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PressRelease

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PressReleasePresenter
  end
end
