# Generated via
#  `rails generate hyrax:work Map`
class Map < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = MapIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :scale, predicate: ::Vocab::RDAE.scale, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :longitud_and_latitud, predicate: ::Vocab::RDAM.longitudAndLatitud, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :digital_representation_of_cartographic_content, predicate: ::Vocab::RDAM.digitalRepresentationOfCartographicContent, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
