# Generated via
#  `rails generate hyrax:work Article`
class Article < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Conacyt

  self.indexer = ArticleIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :period, predicate: ::Vocab::RDAM.alternativeNumericAndOrAlphabeticDesignationOfLastIssueOrPartOfSequence, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :part, predicate: ::Vocab::RDAM.alternativeNumericAndOrAlphabeticDesignationOfFirstIssueOrPartOfSequence, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end  

  property :year, predicate: ::Vocab::RDAM.chronologicalDesignationOfFirstIssueOrPartOfSequence, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 

  property :volume, predicate: ::Vocab::RDAM.numberingOfSerials, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 

  property :number, predicate: ::Vocab::RDAM.numberingWithinSubseries, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 

  property :mode_of_issuance, predicate: ::Vocab::RDAM.modeOfIssuance, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 

  property :pages, predicate: ::RDF::Vocab::SCHEMA.pagination, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 
  
  property :contained_in, predicate: ::Vocab::RDAW.containedWork, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end 

  property :database, predicate: ::Vocab::RDAZ.sourceConsulted, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end
  
  property :issn, predicate: ::RDF::Vocab::RDAM.issnOfSeries, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
