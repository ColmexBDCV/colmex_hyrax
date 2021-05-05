# Generated via
#  `rails generate hyrax:work Music`
module Hyrax
  # Generated controller for Music
  class MusicsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Music

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::MusicPresenter
  end
end
