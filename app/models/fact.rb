# Generated via
#  `rails generate hyrax:work Fact`
class Fact < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = FactIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :related_place_of_timespan, predicate: ::Vocab::RDAT.relatedPlaceOfTimespan, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include LegalDocuments
  include ::Hyrax::BasicMetadata
end
