# Generated via
#  `rails generate hyrax:work Photography`
class Photography < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = PhotographyIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :photographer_corporate_body_of_work, predicate: ::Vocab::RDAA.photographerCorporateBodyOfWork, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :dimensions_of_still_image, predicate: ::Vocab::RDAM.dimensionsOfStillImage, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
