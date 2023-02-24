# Generated via
#  `rails generate hyrax:work Fact`
module Hyrax
  class FactPresenter < Hyrax::WorkShowPresenter
    include Hyrax::LegalDocumentsPresenter
    delegate :related_place_of_timespan, to: :solr_document
  end
end
