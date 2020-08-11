# Generated via
#  `rails generate hyrax:work Thesis`
class Thesis < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Conacyt

  self.indexer = ThesisIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :director, predicate: ::Vocab::RDAA.degreeSupervisorOf, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :awards, predicate: ::Vocab::RDAE.award, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :academic_degree, predicate: ::Vocab::RDAW.academicDegree, multiple: false do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :type_of_thesis, predicate: ::Vocab::RDAW.dissertationOrThesisInformation, multiple: false do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :degree_program, predicate: ::Vocab::RDAW.grantingInstitutionOrFaculty, multiple: false do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :institution, predicate: ::RDF::Vocab::BF2.grantingInstitution, multiple: false do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end
  
  property :date_of_presentation_of_the_thesis, predicate: ::Vocab::RDAW.yearDegreeGranted, multiple: false do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end
    
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
