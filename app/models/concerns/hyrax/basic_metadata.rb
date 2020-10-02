module Hyrax
  # An optional model mixin to define some simple properties. This must be mixed
  # after all other properties are defined because no other properties will
  # be defined once  accepts_nested_attributes_for is called
  module BasicMetadata
    extend ActiveSupport::Concern

    included do
      property :alternate_title, predicate: ::Vocab::RDAM.variantTitle, multiple: true
      property :other_title, predicate: ::Vocab::RDAM.otherTitleInformation, multiple: false
      
      property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false

      property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false

      property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false
      property :resource_type, predicate: ::RDF::Vocab::DC.DCMIType
      property :creator, predicate: ::Vocab::RDAA.authorOf, multiple: true
      property :contributor, predicate: ::RDF::Vocab::DC11.contributor
      property :description, predicate: ::Vocab::RDAE.summarizationOfTheContent
      property :keyword, predicate: ::RDF::Vocab::SCHEMA.keywords
      # Used for a license
      property :license, predicate: ::RDF::Vocab::DC.rights

      
      # This is for the rights statement
      property :rights_statement, predicate: ::RDF::Vocab::EDM.rights
      property :publisher, predicate: ::Vocab::RDAM.publicationStatement, multiple: true
      property :date_created, predicate: ::Vocab::RDAM.dateOfPublication, multiple: true
      property :subject, predicate: ::Vocab::RDAW.subjectRelationship, multiple: true
      property :subject_person, predicate: ::Vocab::RDAW.subjectPerson, multiple: true
      property :subject_family, predicate: ::Vocab::RDAW.subjectFamily, multiple: true
      property :subject_work, predicate: ::Vocab::RDAW.subjectWork, multiple: true
      property :subject_corporate, predicate: ::Vocab::RDAW.subjectCorporateBody, multiple: true
      property :language, predicate: ::Vocab::RDAM.languageOfTheContent
      property :identifier, predicate: ::Vocab::RDAE::identifierForTheManifestation, multiple: false
      property :based_near, predicate: ::RDF::Vocab::BF2.geographicCoverage, class_name: Hyrax::ControlledVocabularies::Location
      property :geographic_coverage, predicate: ::RDF::Vocab::FOAF.based_near
      property :temporary_coverage, predicate: ::RDF::Vocab::BF2.temporalCoverage
      property :gender_or_form, predicate: ::Vocab::RDAW.formOfWork, multiple: true
      property :related_url, predicate: ::RDF::RDFS.seeAlso
      property :bibliographic_citation, predicate: ::Vocab::RDAM.preferredCitation
      property :source, predicate: ::RDF::Vocab::DC.source
      property :doi, predicate: ::RDF::Vocab::BF2.Doi, multiple: false
      property :isbn, predicate: ::RDF::Vocab::BF2.Isbn, multiple: true 
      property :notes, predicate: ::Vocab::RDAM.noteOnManifestation, multiple: true  
      property :center, predicate: ::RDF::Vocab::SCHEMA.department, multiple: true
      property :classification, predicate: ::RDF::Vocab::BF2.Classification, multiple: true
      property :supplementary_content_or_bibliography, predicate: ::Vocab::RDAE.supplementaryContent, multiple: true
      property :responsibility_statement, predicate: ::Vocab::RDAM.statementOfResponsibilityRelatingToTitleProper, multiple: false
      property :other_related_persons, predicate: ::Vocab::RDAA.otherPFCWorkOf, multiple: true
      property :table_of_contents, predicate: ::Vocab::RDAW.wholePartWorkRelationship, multiple: true
      property :type_of_content, predicate: ::Vocab::RDAU.contentType, multiple: true
      property :type_of_illustrations, predicate: ::Vocab::RDAE.illustrativeContent, multiple: true
      property :reviewer, predicate: ::RDF::Vocab::Bibframe.review, multiple: true 
      property :editor, predicate: ::Vocab::RDAA.isEditorPersonOfTextOf, multiple: true
      property :compiler, predicate: ::Vocab::RDAA.isCompilerAgentFor, multiple: true
      property :commentator, predicate: ::Vocab::RDAA.isCommentatorAgentOf, multiple: true
      property :translator, predicate: ::Vocab::RDAA.isTranslatorAgentOf, multiple: true
      property :mode_of_issuance, predicate: ::Vocab::RDAM.modeOfIssuance, multiple: true
      property :edition, predicate: ::Vocab::RDAM.designationOfEdition, multiple: true
      property :dimensions, predicate: ::Vocab::RDAM.dimensions, multiple: false
      property :extension, predicate: ::Vocab::RDAM.extent, multiple: false
      property :system_requirements, predicate: ::Vocab::RDAM.equipmentOrSystemRequirement, multiple: true

      property :item_access_restrictions, predicate: ::Vocab::RDAI.restrictionsOnAccessToItem, multiple: true
      property :item_use_restrictions, predicate: ::Vocab::RDAI.restrictionsOnUseOfItem, multiple: true
      property :encoding_format_details, predicate: ::Vocab::RDAM.detailsOfEncodingFormat, multiple: true
      property :digital_resource_generation_information, predicate: ::Vocab::RDAM.detailsOfGenerationOfDigitalResource, multiple: true

      property :interviewer, predicate: ::Vocab::RDAA.interviewerAgentOf, multiple: true
      property :interviewee, predicate: ::Vocab::RDAA.intervieweeAgentOf, multiple: true
      property :organizer_collective_agent, predicate: ::Vocab::RDAA.organizerCollectiveAgent, multiple: true
      property :photographer, predicate: ::Vocab::RDAA.photographerAgnteOf, multiple: true
      property :collective_title, predicate: ::RDF::Vocab::BF2.CollectiveTitle, multiple: true
      property :part_of_place, predicate: ::Vocab::RDAC.partOfPlace, multiple: true
      property :provenance, predicate: ::RDF::Vocab::DC.provenance, multiple: true
      property :curator_collective_agent_of, predicate: ::Vocab::RDAA.curatorCollectiveAgentOf, multiple: true
      property :project, predicate: ::RDF::Vocab::FOAF.Project, multiple: true
      property :owner_agent_of, predicate: ::Vocab::RDAA.ownerAgentOf, multiple: true
      property :custodian_agent_of, predicate: ::Vocab::RDAA.custodianAgentOf, multiple: true
      property :file_type_details, predicate: ::Vocab::RDAM.detailsOfFileType, multiple: true


      
      id_blank = proc { |attributes| attributes[:id].blank? }

      class_attribute :controlled_properties
      self.controlled_properties = [:based_near]
      accepts_nested_attributes_for :based_near, reject_if: id_blank, allow_destroy: true
    end
  end
end
