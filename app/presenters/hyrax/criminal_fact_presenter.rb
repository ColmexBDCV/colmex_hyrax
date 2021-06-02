# Generated via
#  `rails generate hyrax:work CriminalFact`
module Hyrax
  class CriminalFactPresenter < Hyrax::WorkShowPresenter
    delegate :related_place_of_timespan, :note_of_timespan, to: :solr_document
  end
end
