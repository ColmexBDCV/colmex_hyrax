# Generated via
#  `rails generate hyrax:work DataBase`
class Database < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = DatabaseIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
   
  property :summary_of_work, predicate: ::Vocab::RDAW.summary_of_work, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :nature_of_content, predicate: ::Vocab::RDAW.nature_of_content, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :guide_to_work, predicate: ::Vocab::RDAW.guide_to_work, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :analysis_of_work, predicate: ::Vocab::RDAW.analysis_of_work, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :complemented_by_work, predicate: ::Vocab::RDAW.complemented_by_work, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :production_method, predicate: ::Vocab::RDAM.production_method, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
