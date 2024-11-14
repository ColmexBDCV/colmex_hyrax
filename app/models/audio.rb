# Generated via
#  `rails generate hyrax:work Audio`
class Audio < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = AudioIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }


  property :is_lyricist_person_of, predicate: ::Vocab::RDAA.isLyricistPersonOf, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :is_composer_person_of, predicate: ::Vocab::RDAA.isComposerPersonOf, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :is_performer_agent_of, predicate: ::Vocab::RDAA.isPerformerAgentOf, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :is_instrumentalist_agent_of, predicate: ::Vocab::RDAA.isInstrumentalistAgentOf, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :is_singer_agent_of, predicate: ::Vocab::RDAA.isSingerAgentOf, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :has_medium_of_performance_of_musical_content, predicate: ::Vocab::RDAU.hasMediumOfPerformanceOfMusicalContent, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
