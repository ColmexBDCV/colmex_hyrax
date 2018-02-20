# Generated via
#  `rails generate hyrax:work Work`
class Work < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = WorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Work'

  property :creator_conacyt, predicate: ::RDF::Vocab::MODS.namePrincipal, multiple: true do |index|
    index.type :text
    index.as :stored_searchable
  end

  property :contributor_conacyt, predicate: ::RDF::Vocab::MODS.name, multiple: true do |index|
    index.type :text
    index.as :stored_searchable
  end

  property :subject_conacyt, predicate: ::RDF::Vocab::MODS.subjectTopic, multiple: false do |index|
    index.type :text
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

end
