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

  property :item_access_restrictions, predicate: ::Vocab::RDAI.restrictionsOnAccessToItem, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :item_use_restrictions, predicate: ::Vocab::RDAI.restrictionsOnUseOfItem, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :edition, predicate: ::Vocab::RDAM.designationOfEdition, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :encoding_format_details, predicate: ::Vocab::RDAM.detailsOfEncodingFormat, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :file_type_details, predicate: ::Vocab::RDAM.detailsOfFileType, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :digital_resource_generation_information, predicate: ::Vocab::RDAM.detailsOfGenerationOfDigitalResource, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :file_details, predicate: ::Vocab::RDAM.digitalFileCharacteristic, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :dimensions, predicate: ::Vocab::RDAM.dimensions, multiple: false do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :system_requirements, predicate: ::Vocab::RDAM.equipmentOrSystemRequirement, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :exemplar_of_manifestation, predicate: ::Vocab::RDAM.exemplarOfManifestation, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :extension, predicate: ::Vocab::RDAM.extent, multiple: false do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :type_of_file, predicate: ::Vocab::RDAM.fileType, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end
  
  # property :mode_of_publication, predicate: ::Vocab::RDAM.modeOfIssuance, multiple: false do |index|
  #   index.type :text
  #   index.as :stored_searchable, :facetable
  # end

  property :other_formats, predicate: ::Vocab::RDAM.relatedManifestation, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :access_restrictions, predicate: ::Vocab::RDAM.restrictionsOnAccessToManifestation, multiple: true do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :use_restrictions, predicate: ::Vocab::RDAM.restrictionsOnUseOfManifestation, multiple: true do |index|
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
