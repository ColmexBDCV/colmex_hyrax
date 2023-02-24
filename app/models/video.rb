# Generated via
#  `rails generate hyrax:work Video`
class Video < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Series

  self.indexer = VideoIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :video_format, predicate: ::Vocab::RDAM.videoFormat, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end
  
  property :video_characteristic, predicate: ::Vocab::RDAM.hasVideoCharacteristic, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end
  
  property :note_on_statement_of_responsibility, predicate: ::Vocab::RDAM.noteOnStatementOfResposibility, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  
  include ::Hyrax::BasicMetadata
end
