# Generated via
#  `rails generate hyrax:work JurisprudentialThesis`
class JurisprudentialThesis < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include LegalDocuments

  self.indexer = JurisprudentialThesisIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :period_of_activity_of_corporate_body, predicate: ::Vocab::RDAA.periodOfActivityOfCorporateBody, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :speaker_agent_of, predicate: ::Vocab::RDAA.speakerAgentOf, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :assistant, predicate: ::Vocab::RDAA.assistant, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :preceded_by_work, predicate: ::Vocab::RDAW.precededByWork, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end
  
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
