module Hyrax
  # An optional model mixin to define some simple properties. This must be mixed
  # after all other properties are defined because no other properties will
  # be defined once  accepts_nested_attributes_for is called
  module BasicMetadata
    extend ActiveSupport::Concern
    include Coordinates

    included do
      property :alternate_title, predicate: ::Vocab::RDAM.variantTitle, multiple: true
      property :other_title, predicate: ::Vocab::RDAM.otherTitleInformation, multiple: false
      
      property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false

      property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false

      property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false
      property :resource_type, predicate: ::RDF::Vocab::DC.DCMIType, multiple: true
      property :creator, predicate: ::Vocab::RDAA.authorOf, multiple: true
      property :contributor, predicate: ::RDF::Vocab::DC11.contributor, multiple: true
      property :has_creator, predicate: ::Vocab::RDAU.hasCreator, multiple: true
      property :description, predicate: ::Vocab::RDAE.summarizationOfTheContent
      property :keyword, predicate: ::RDF::Vocab::SCHEMA.keywords
      # Used for a license
      property :license, predicate: ::RDF::Vocab::DC.rights
      property :handle, predicate: ::RDF::Vocab::DataCite.handle, multiple: false 
      property :thematic_collection, predicate: ::RDF::Vocab::BF2.Collection, multiple: true
      
      # This is for the rights statement
      property :rights_statement, predicate: ::RDF::Vocab::EDM.rights
      property :publisher, predicate: ::Vocab::RDAM.publicationStatement, multiple: true
      property :date_created, predicate: ::Vocab::RDAM.dateOfPublication, multiple: true
      property :subject, predicate: ::Vocab::RDAW.subjectRelationship, multiple: true
      property :subject_person, predicate: ::Vocab::RDAW.subjectPerson, multiple: true
      property :subject_family, predicate: ::Vocab::RDAW.subjectFamily, multiple: true
      property :subject_work, predicate: ::Vocab::RDAW.subjectWork, multiple: true
      property :subject_corporate, predicate: ::Vocab::RDAW.subjectCorporateBody, multiple: true
      property :language, predicate: ::Vocab::RDAM.languageOfTheContent, multiple: true
      property :identifier, predicate: ::Vocab::RDAE::identifierForTheManifestation, multiple: false
      property :based_near, predicate: ::RDF::Vocab::BF2.geographicCoverage, class_name: Hyrax::ControlledVocabularies::Location
      property :geographic_coverage, predicate: ::RDF::Vocab::FOAF.based_near
      property :temporary_coverage, predicate: ::RDF::Vocab::BF2.temporalCoverage
      property :gender_or_form, predicate: ::Vocab::RDAW.formOfWork, multiple: true
      property :related_url, predicate: ::RDF::RDFS.seeAlso, multiple: true
      property :bibliographic_citation, predicate: ::Vocab::RDAM.preferredCitation
      property :source, predicate: ::RDF::Vocab::DC.source

      property :related_work_of_work, predicate: ::Vocab::RDAW.hasRelatedWorkOfWork, multiple: true
      property :numbering_of_part, predicate: ::Vocab::RDAW.hasNumberingOfPart, multiple: false

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
      property :mode_of_issuance, predicate: ::Vocab::RDAM.modeOfIssuance, multiple: false
      property :edition, predicate: ::Vocab::RDAM.designationOfEdition, multiple: true
      property :dimensions, predicate: ::Vocab::RDAM.dimensions, multiple: false
      property :extension, predicate: ::Vocab::RDAM.extent, multiple: false
      property :system_requirements, predicate: ::Vocab::RDAM.equipmentOrSystemRequirement, multiple: false
      property :encoding_format_details, predicate: ::Vocab::RDAM.detailsOfEncodingFormat, multiple: true
      property :digital_resource_generation_information, predicate: ::Vocab::RDAM.detailsOfGenerationOfDigitalResource, multiple: true
      property :contained_in, predicate: ::Vocab::RDAW.containedWork, multiple: true
      property :collector_collective_agent, predicate: ::Vocab::RDAM.collectorCollectiveAgent, multiple: true

      property :has_system_of_organization, predicate: ::Vocab::RDAW.hasSystemOfOrganization, multiple: true
      property :is_subcollection_of, predicate: ::Vocab::RDAU.isSubCollection, multiple: true

      property :interviewer, predicate: ::Vocab::RDAA.interviewerAgentOf, multiple: true
      property :interviewee, predicate: ::Vocab::RDAA.intervieweeAgentOf, multiple: true
      property :draftsman, predicate: ::Vocab::RDAA.isDraftsmanAgentOf, multiple: true
      property :organizer_collective_agent, predicate: ::Vocab::RDAA.organizerCollectiveAgent, multiple: true
      property :photographer, predicate: ::Vocab::RDAA.isPhotographerAgentOf, multiple: true
      property :narrator, predicate: ::Vocab::RDAA.isNarratorAgentOf, multiple: true
      property :collective_title, predicate: ::RDF::Vocab::BF2.CollectiveTitle, multiple: true
      property :part_of_place, predicate: ::Vocab::RDAC.partOfPlace, multiple: true
      property :provenance, predicate: ::RDF::Vocab::DC.provenance, multiple: true
      property :curator_collective_agent_of, predicate: ::Vocab::RDAA.curatorCollectiveAgentOf, multiple: true
      property :project, predicate: ::RDF::Vocab::FOAF.Project, multiple: true
      property :owner_agent_of, predicate: ::Vocab::RDAA.ownerAgentOf, multiple: true
      property :custodian_agent_of, predicate: ::Vocab::RDAA.custodianAgentOf, multiple: true
      property :depository_collective_agent_of, predicate: ::Vocab::RDAI.depositoryCollectiveAgent, multiple: true
      property :depository_agent, predicate: ::Vocab::RDAI.depositoryAgent, multiple: true
      property :file_type_details, predicate: ::Vocab::RDAM.detailsOfFileType, multiple: true
      property :corporate_body, predicate: ::Vocab::RDAC.corporateBody, multiple: true
      property :collective_agent, predicate: ::Vocab::RDAC.collectiveAgent, multiple: true
      property :digital_file_characteristics, predicate: ::Vocab::RDAM.digitalFileCharacteristic, multiple: true
      property :writer_of_suplementary_textual_content, predicate: ::Vocab::RDAA.isWriterOfSuplementaryTextualContent, multiple: true
      property :organizer_collective_agent, predicate: ::Vocab::RDAA.isOrganizerCollectiveAgentOf, multiple: true
      property :has_field_activity_of_agent, predicate: ::Vocab::RDAU.hasFieldOfActivityofAgent, multiple: true
      property :place_of_publication, predicate: ::Vocab::RDAM.placeOfPublication, multiple: true
      property :is_facsimile_of_manifestation_of, predicate: ::Vocab::RDAM.isFacsimilOfManifestationOf, multiple: true
      property :beginning, predicate: ::Vocab::RDAT.hasBeginning, multiple: false
      property :ending, predicate: ::Vocab::RDAT.hasEnding, multiple: false
      property :date_of_manifestation, predicate: ::Vocab::RDAM.dateOfManifestation, multiple: false
      property :subject_uniform_title, predicate: ::Vocab::RDAW.subjectUniformTitle, multiple: false
      property :resource_access_restrictions, predicate: ::Vocab::RDAM.resourceAccessRestrictions, multiple: true
      property :resource_use_restrictions, predicate: ::Vocab::RDAM.restrictionsOnUseOfResource, multiple: true
      property :manifestation_access_restrictions, predicate: ::Vocab::RDAM.restrictionsOnAccessToManifestation, multiple: true
      property :manifestation_use_restrictions, predicate: ::Vocab::RDAM.restrictionsOnUseOfManifestation, multiple: true
      property :item_access_restrictions, predicate: ::Vocab::RDAI.restrictionsOnAccessToItem, multiple: true
      property :item_use_restrictions, predicate: ::Vocab::RDAI.restrictionsOnUseOfItem, multiple: true
      
     
      id_blank = proc { |attributes| attributes[:id].blank? }

      class_attribute :controlled_properties
      self.controlled_properties = [:based_near]
      accepts_nested_attributes_for :based_near, reject_if: id_blank, allow_destroy: true
    end
  end
end
