# Generated via
#  `rails generate hyrax:work CriminalFact`
class CriminalFact < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = CriminalFactIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :related_place_of_timespan, predicate: ::Vocab::RDAT.relatedPlaceOfTimespan, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :note_of_timespan, predicate: ::Vocab::RDAT.noteOfTimeSpan, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
