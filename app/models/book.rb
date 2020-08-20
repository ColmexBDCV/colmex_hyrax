# Generated via
#  `rails generate hyrax:work Book`
class Book < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Conacyt


  self.indexer = BookIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :corporate_body, predicate: ::Vocab::RDAC.corporateBody, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 

  property :collective_agent, predicate: ::Vocab::RDAC.collectiveAgent, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 

  property :organizer_author, predicate: ::Vocab::RDAA.organizerAgentOf, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 

  property :place_of_publication, predicate: ::Vocab::RDAM.placeOfPublication, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 

  property :copyright, predicate: ::Vocab::RDAM.copyrightDate, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 

  property :title_of_series, predicate: ::Vocab::RDAM.titleOfSeries, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 

  property :numbering_within_sequence, predicate: ::Vocab::RDAM.numberingOfSequence, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
