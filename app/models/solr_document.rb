# frozen_string_literal: true
class SolrDocument
  
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocument

  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models. 

  use_extension( Hydra::ContentNegotiation )

  def identifier
    self['identifier_tesim']
  end

  def notes
    self['notes_tesim']
  end

  def geographic_coverage
    self['geographic_coverage_tesim']
  end

  def temporary_coverage
    self['temporary_coverage_tesim']
  end

  def gender_or_form
    self['gender_or_form_tesim']
  end

  def subject_conacyt
    self['subject_conacyt_tesim']
  end

  def pub_conacyt
    self['pub_conacyt_tesim']
  end

  def contributor_conacyt
    self['contributor_conacyt_tesim']
  end

  def other_title
    self['other_title_tesim']
  end

  def subject_person
    self['subject_person_tesim']
  end

  def subject_family
    self['subject_family_tesim']
  end

  def subject_work
    self['subject_work_tesim']
  end

  def subject_corporate
    self['subject_corporate_tesim']
  end
  
  def alternate_title
    self['alternate_title_tesim']
  end
 
  def creator_conacyt
    self['creator_conacyt_tesim']
  end

  def director
    self['director_tesim']
  end

  def other_related_persons
    self['other_related_persons_tesim']
  end

  def awards
    self['awards_tesim']
  end

  def type_of_content
    self['type_of_content_tesim']
  end

  def type_of_illustrations
    self['type_of_illustrations_tesim']
  end

  def supplementary_content_or_bibliography
    self['supplementary_content_or_bibliography_tesim']
  end

  def item_access_restrictions
    self['item_access_restrictions_tesim']
  end

  def item_use_restrictions
    self['item_use_restrictions_tesim']
  end

  def encoding_format_details
    self['encoding_format_details_tesim']
  end

  def file_type_details
    self['file_type_details_tesim']
  end

  def depository_collective_agent_of
    self['depository_collective_agent_of_tesim']
  end

  def depository_agent
    self['depository_agent_tesim']
  end

  def is_part_or_work
    self['is_part_or_work_tesim']
  end
  
  def digital_resource_generation_information
    self['digital_resource_generation_information_tesim']
  end

  def file_details
    self['file_details_tesim']
  end

  def dimensions
    self['dimensions_tesim']
  end

  def system_requirements
    self['system_requirements_tesim']
  end

  def exemplar_of_manifestation
    self['exemplar_of_manifestation_tesim']
  end

  def extension
    self['extension_tesim']
  end

  def type_of_file
    self['type_of_file_tesim']
  end

  def doi
    self['doi_tesim']
  end

  def isbn
    self['isbn_tesim']
  end

  def mode_of_publication
    self['mode_of_publication_tesim']
  end

  def other_formats
    self['other_formats_tesim']
  end

  def access_restrictions
    self['access_restrictions_tesim']
  end

  def use_restrictions
    self['use_restrictions_tesim']
  end

  def responsibility_statement
    self['responsibility_statement_tesim']
  end

  def academic_degree
    self['academic_degree_tesim']
  end

  def type_of_thesis
    self['type_of_thesis_tesim']
  end

  def degree_program
    self['degree_program_tesim']
  end

  def institution
    self['institution_tesim']
  end

  def center
    self['center_tesim']
  end

  def classification
    self['classification_tesim']
  end

  def table_of_contents
    self['table_of_contents_tesim']
  end

  def date_of_presentation_of_the_thesis
    self['date_of_presentation_of_the_thesis_tesim']
  end

  def themes
    self['themes_tesim']
  end
   
  def period
    self['period_tesim']
  end

  def part
    self['part_tesim']
  end
  
  def year
    self['year_tesim']
  end

  def volume
    self['volume_tesim']
  end

  def number
    self['number_tesim']
  end

  def mode_of_issuance
    self['mode_of_issuance_tesim']
  end

  def pages
    self['pages_tesim']
  end

  def contained_in
    self['contained_in_tesim']
  end

  def database
    self['database_tesim']
  end

  def issn
    self['issn_tesim']
  end

  def reviewer
    self['reviewer_tesim']
  end
  
  def editor
    self['editor_tesim']
  end

  def compiler
    self['compiler_tesim']
  end
  
  def commentator
    self['commentator_tesim']
  end 

  def organizer
    self['organizer_tesim']
  end 

  def translator
    self['translator_tesim']
  end 
  
  def edition
    self['edition_tesim']
  end

  def corporate_body
    self['corporate_body_tesim']
  end

  def collective_agent
    self['collective_agent_tesim']
  end

  def organizer_author
    self['organizer_author_tesim']
  end

  def place_of_publication
    self['place_of_publication_tesim']
  end

  def copyright
    self['copyright_tesim']
  end

  def title_of_series
    self['title_of_series_tesim']
  end

  def numbering_within_sequence
    self['numbering_within_sequence_tesim']
  end

  def video_format
    self['video_format_tesim']
  end

  def video_characteristic
    self['video_characteristic_tesim']
  end

  def note_on_statement_of_resposibility
    self['note_on_statement_of_responsibility_tesim']
  end
  
  def interviewer
    self['interviewer_tesim']
  end

  def interviewee
    self['interviewee_tesim']
  end

  def organizer_collective_agent
    self['organizer_collective_agent_tesim']
  end

  def photographer
    self['photographer_tesim']
  end 

  def collective_title
    self['collective_title_tesim']
  end

  def part_of_place
    self['part_of_place_tesim']
  end

  def provenance
    self['provenance_tesim']
  end

  def curator_collective_agent_of
    self['curator_collective_agent_of_tesim']
  end

  def project
    self['project_tesim']
  end 

  def owner_agent_of
    self['owner_agent_of_tesim']
  end

  def custodian_agent_of
    self['custodian_agent_of_tesim']
  end

  def file_type_details
    self['file_type_details_tesim']
  end

  def is_lyricist_person_of 
    self['is_lyricist_person_of_tesim']
  end
  
  def is_composer_person_of
    self['is_composer_person_of_tesim']
  end
  
  def researcher_agent_of
    self['researcher_agent_of_tesim']
  end

  def summary_of_work
    self['summary_of_work_tesim']
  end

  def nature_of_content
    self['nature_of_content_tesim']
  end

  def guide_to_work
    self['guide_to_work_tesim']
  end

  def analysis_of_work
    self['analysis_of_work_tesim']
  end

  def complemented_by_work
    self['complemented_by_work_tesim']
  end

  def production_method
    self['production_method_tesim']
  end

  def scale
    self['scale_tesim']
  end

  def longitud_and_latitud
    self['longitud_and_latitud_tesim']
  end

  def digital_representation_of_cartographic_content
    self['digital_representation_of_cartographic_content_tesim']
  end

  def related_place_of_timespan
    self['related_place_of_timespan_tesim']
  end

  def note_of_timespan
    self['note_of_timespan_tesim']
  end

  def alternative_numeric_and_or_alphabethic_designation
    self['alternative_numeric_and_or_alphabethic_designation_tesim']
  end

  def photographer_corporate_body_of_work
    self['photographer_corporate_body_of_work_tesim']
  end

  def dimensions_of_still_image
    self['dimensions_of_still_image_tesim']
  end

  def period_of_activity_of_corporate_body
    self['period_of_activity_of_corporate_body_tesim']
  end

  def speaker_agent_of
    self['speaker_agent_of_tesim']
  end

  def assistant
    self['assistant_tesim']
  end

  def preceded_by_work
    self['preceded_by_work_tesim']
  end

  def primary_topic
    self['primary_topic_tesim']
  end

  def enacting_juridiction_of
    self['enacting_juridiction_of_tesim']
  end

  def hierarchical_superior
    self['hierarchical_superior_tesim']
  end

  def hierarchical_inferior
    self['hierarchical_inferior_tesim']
  end

  def subject_timespan
    self['subject_timespan_tesim']
  end

  def identifier_of_work
    self['identifier_of_work_tesim']
  end

  def is_title_of_item_of
    self['is_title_of_item_of_tesim']
  end

  def timespan_described_in
    self['timespan_described_in_tesim']
  end

  def related_person_of
    self['related_person_of_tesim']
  end

  def related_corporate_body_of_timespan
    self['related_corporate_body_of_timespan_tesim']
  end

  def related_family_timespan
    self['related_family_timespan_tesim']
  end

  def handle
    self['handle_tesim']
  end

  def digital_file_characteristics
    self['digital_file_characteristics_tesim']
  end

  def has_creator
    self['has_creator_tesim']
  end

  def narrator
    self['narrator_tesim']
  end

  def writer_of_suplementary_textual_content
    self['writer_of_suplementary_textual_content_tesim']
  end

  def organizer_collective_agent
    self['organizer_collective_agent_tesim']
  end 

  def has_field_activity_of_agent
    self['has_field_activity_of_agent_tesim']
  end

  def place_of_publication
    self['place_of_publication_tesim']
  end

  def is_facsimile_of_manifestation_of
    self['is_facsimile_of_manifestation_of_tesim']
  end

  def beginning
    self['beginning_tesim']
  end

  def ending
    self['ending_tesim']
  end

  def date_of_manifestation
    self['date_of_manifestation_tesim']
  end

  def resource_access_restrictions
    self['resource_access_restrictions_tesim']
  end

  def resource_use_restrictions
    self['resource_use_restrictions_tesim']
  end

  def manifestation_access_restrictions
    self['manifestation_access_restrictions_tesim']
  end

  def manifestation_use_restrictions
    self['manifestation_use_restrictions_tesim']
  end

  def item_access_restrictions
    self['item_access_restrictions_tesim']
  end

  def item_use_restrictions
    self['item_use_restrictions_tesim']
  end

  def complainant
    self['complainant_tesim']
  end

  def contestee
    self['contestee_tesim']
  end

  def witness
    self['witness_tesim']
  end

  def subject_uniform_title
    self['subject_uniform_title_tesim']
  end

  def is_criminal_defendant_person_of
    self['is_criminal_defendant_person_of_tesim']
  end

  def is_criminal_defendant_corporate_body_of
    self['is_criminal_defendant_corporate_body_of_tesim']
  end

  def has_identifier_for_item
    self['has_identifier_for_item_tesim']
  end

  def is_finding_aid_for
    self['is_finding_aid_for_tesim']
  end

  def collector_collective_agent
    self['collector_collective_agent_tesim']
  end
  
  def thematic_collection
    self['thematic_collection_tesim']
  end

  def draftsman
    self['draftsman_tesim']
  end

  def related_work_of_work
    self['related_work_of_work_tesim'] 
  end
  
  def numbering_of_part
    self['numbering_of_part_tesim'] 
  end

  def has_system_of_organization
    self['has_system_of_organization_tesim'] 
  end

  def is_subcollection_of
    self['is_subcollection_of_tesim'] 
  end
end