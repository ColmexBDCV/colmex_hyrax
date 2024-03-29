# Generated via
#  `rails generate hyrax:work LegalCase`
class LegalCase < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = LegalCaseIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  include LegalDocuments
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
