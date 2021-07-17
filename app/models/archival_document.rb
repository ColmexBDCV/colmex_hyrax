# Generated via
#  `rails generate hyrax:work ArchivalDocument`
class ArchivalDocument < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = ArchivalDocumentIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :is_finding_aid_for, predicate: ::Vocab::RDAU.isFindingAidFor, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
