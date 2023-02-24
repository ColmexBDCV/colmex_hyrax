# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocument

  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  field_semantics.merge!(
                         contributor: Solrizer.solr_name('contributor'),
                         coverage:    Solrizer.solr_name('spatial'),
                         creator:     Solrizer.solr_name('creator'),
                         date:        Solrizer.solr_name('date_created'),
                         description: Solrizer.solr_name('description'),
                         format:      Solrizer.solr_name('format'),
                         identifier:  'oai_identifier',
                         language:    Solrizer.solr_name('language'),
                         creator_conacyt:    Solrizer.solr_name('creator_conacyt'),
                         contributor_conacyt:    Solrizer.solr_name('contributor_conacyt'),
                         publisher:   Solrizer.solr_name('publisher'),
                         rights:      Solrizer.solr_name('license'),
                         source:      Solrizer.solr_name('source'),
                         subject:     Solrizer.solr_name('subject'),
                         subject_person:     Solrizer.solr_name('subject_person'),
                         subject_family:     Solrizer.solr_name('subject_family'),
                         subject_work:     Solrizer.solr_name('subject_work'),
                         subject_conacyt:     Solrizer.solr_name('subject_conacyt'),
                         themes:      Solrizer.solr_name('themes'),
                         audience:     Solrizer.solr_name('pub_conacyt'),
                         title:       Solrizer.solr_name('title'),
                         type:        Solrizer.solr_name('type_conacyt'),
                        )

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
    self[Solrizer.solr_name('identifier')]
  end

  def notes
    self[Solrizer.solr_name('notes')]
  end

  def geographic_coverage
    self[Solrizer.solr_name('geographic_coverage')]
  end

  def temporary_coverage
    self[Solrizer.solr_name('temporary_coverage')]
  end

  def gender_or_form
    self[Solrizer.solr_name('gender_or_form')]
  end

  def subject_conacyt
    self[Solrizer.solr_name('subject_conacyt')]
  end

  def pub_conacyt
    self[Solrizer.solr_name('pub_conacyt')]
  end

  def contributor_conacyt
    self[Solrizer.solr_name('contributor_conacyt')]
  end

  def other_title
    self[Solrizer.solr_name('other_title')]
  end

  def subject_person
    self[Solrizer.solr_name('subject_person')]
  end

  def subject_family
    self[Solrizer.solr_name('subject_family')]
  end

  def subject_work
    self[Solrizer.solr_name('subject_work')]
  end

  def subject_corporate
    self[Solrizer.solr_name('subject_corporate')]
  end
  
  def alternate_title
    self[Solrizer.solr_name('alternate_title')]
  end
 
  def creator_conacyt
    self[Solrizer.solr_name('creator_conacyt')]
  end

  def director
    self[Solrizer.solr_name('director')]
  end

  def other_related_persons
    self[Solrizer.solr_name('other_related_persons')]
  end

  def awards
    self[Solrizer.solr_name('awards')]
  end

  def type_of_content
    self[Solrizer.solr_name('type_of_content')]
  end

  def type_of_illustrations
    self[Solrizer.solr_name('type_of_illustrations')]
  end

  def supplementary_content_or_bibliography
    self[Solrizer.solr_name('supplementary_content_or_bibliography')]
  end

  def item_access_restrictions
    self[Solrizer.solr_name('item_access_restrictions')]
  end

  def item_use_restrictions
    self[Solrizer.solr_name('item_use_restrictions')]
  end

  def encoding_format_details
    self[Solrizer.solr_name('encoding_format_details')]
  end

  def file_type_details
    self[Solrizer.solr_name('file_type_details')]
  end

  def depository_collective_agent_of
    self[Solrizer.solr_name('depository_collective_agent_of')]
  end

  def depository_agent
    self[Solrizer.solr_name('depository_agent')]
  end

  def is_part_or_work
    self[Solrizer.solr_name('is_part_or_work')]
  end
  
  def digital_resource_generation_information
    self[Solrizer.solr_name('digital_resource_generation_information')]
  end

  def file_details
    self[Solrizer.solr_name('file_details')]
  end

  def dimensions
    self[Solrizer.solr_name('dimensions')]
  end

  def system_requirements
    self[Solrizer.solr_name('system_requirements')]
  end

  def exemplar_of_manifestation
    self[Solrizer.solr_name('exemplar_of_manifestation')]
  end

  def extension
    self[Solrizer.solr_name('extension')]
  end

  def type_of_file
    self[Solrizer.solr_name('type_of_file')]
  end

  def doi
    self[Solrizer.solr_name('doi')]
  end

  def isbn
    self[Solrizer.solr_name('isbn')]
  end

  def mode_of_publication
    self[Solrizer.solr_name('mode_of_publication')]
  end

  def other_formats
    self[Solrizer.solr_name('other_formats')]
  end

  def access_restrictions
    self[Solrizer.solr_name('access_restrictions')]
  end

  def use_restrictions
    self[Solrizer.solr_name('use_restrictions')]
  end

  def responsibility_statement
    self[Solrizer.solr_name('responsibility_statement')]
  end

  def academic_degree
    self[Solrizer.solr_name('academic_degree')]
  end

  def type_of_thesis
    self[Solrizer.solr_name('type_of_thesis')]
  end

  def degree_program
    self[Solrizer.solr_name('degree_program')]
  end

  def institution
    self[Solrizer.solr_name('institution')]
  end

  def center
    self[Solrizer.solr_name('center')]
  end

  def classification
    self[Solrizer.solr_name('classification')]
  end

  def table_of_contents
    self[Solrizer.solr_name('table_of_contents')]
  end

  def date_of_presentation_of_the_thesis
    self[Solrizer.solr_name('date_of_presentation_of_the_thesis')]
  end

  def themes
    self[Solrizer.solr_name('themes')]
  end
   
  def period
    self[Solrizer.solr_name('period')]
  end

  def part
    self[Solrizer.solr_name('part')]
  end
  
  def year
    self[Solrizer.solr_name('year')]
  end

  def volume
    self[Solrizer.solr_name('volume')]
  end

  def number
    self[Solrizer.solr_name('number')]
  end

  def mode_of_issuance
    self[Solrizer.solr_name('mode_of_issuance')]
  end

  def pages
    self[Solrizer.solr_name('pages')]
  end

  def contained_in
    self[Solrizer.solr_name('contained_in')]
  end

  def database
    self[Solrizer.solr_name('database')]
  end

  def issn
    self[Solrizer.solr_name('issn')]
  end

  def reviewer
    self[Solrizer.solr_name('reviewer')]
  end
  
  def editor
    self[Solrizer.solr_name('editor')]
  end

  def compiler
    self[Solrizer.solr_name('compiler')]
  end
  
  def commentator
    self[Solrizer.solr_name('commentator')]
  end 

  def translator
    self[Solrizer.solr_name('translator')]
  end 
  
  def edition
    self[Solrizer.solr_name('edition')]
  end

  def corporate_body
    self[Solrizer.solr_name('corporate_body')]
  end

  def collective_agent
    self[Solrizer.solr_name('collective_agent')]
  end

  def organizer_author
    self[Solrizer.solr_name('organizer_author')]
  end

  def place_of_publication
    self[Solrizer.solr_name('place_of_publication')]
  end

  def copyright
    self[Solrizer.solr_name('copyright')]
  end

  def title_of_series
    self[Solrizer.solr_name('title_of_series')]
  end

  def numbering_within_sequence
    self[Solrizer.solr_name('numbering_within_sequence')]
  end

  def video_format
    self[Solrizer.solr_name('video_format')]
  end

  def video_characteristic
    self[Solrizer.solr_name('video_characteristic')]
  end

  def note_on_statement_of_responsibility
    self[Solrizer.solr_name('note_on_statement_of_responsibility')]
  end
  
  def interviewer
    self[Solrizer.solr_name('interviewer')]
  end

  def interviewee
    self[Solrizer.solr_name('interviewee')]
  end

  def organizer_collective_agent
    self[Solrizer.solr_name('organizer_collective_agent')]
  end

  def photographer
    self[Solrizer.solr_name('photographer')]
  end 

  def collective_title
    self[Solrizer.solr_name('collective_title')]
  end

  def part_of_place
    self[Solrizer.solr_name('part_of_place')]
  end

  def provenance
    self[Solrizer.solr_name('provenance')]
  end

  def curator_collective_agent_of
    self[Solrizer.solr_name('curator_collective_agent_of')]
  end

  def project
    self[Solrizer.solr_name('project')]
  end 

  def owner_agent_of
    self[Solrizer.solr_name('owner_agent_of')]
  end

  def custodian_agent_of
    self[Solrizer.solr_name('custodian_agent_of')]
  end

  def file_type_details
    self[Solrizer.solr_name('file_type_details')]
  end

  def is_lyricist_person_of 
    self[Solrizer.solr_name('is_lyricist_person_of')]
  end
  
  def is_composer_person_of
    self[Solrizer.solr_name('is_composer_person_of')]
  end
  
  def researcher_agent_of
    self[Solrizer.solr_name('researcher_agent_of')]
  end

  def summary_of_work
    self[Solrizer.solr_name('summary_of_work')]
  end

  def nature_of_content
    self[Solrizer.solr_name('nature_of_content')]
  end

  def guide_to_work
    self[Solrizer.solr_name('guide_to_work')]
  end

  def analysis_of_work
    self[Solrizer.solr_name('analysis_of_work')]
  end

  def complemented_by_work
    self[Solrizer.solr_name('complemented_by_work')]
  end

  def production_method
    self[Solrizer.solr_name('production_method')]
  end

  def scale
    self[Solrizer.solr_name('scale')]
  end

  def longitud_and_latitud
    self[Solrizer.solr_name('longitud_and_latitud')]
  end

  def digital_representation_of_cartographic_content
    self[Solrizer.solr_name('digital_representation_of_cartographic_content')]
  end

  def related_place_of_timespan
    self[Solrizer.solr_name('related_place_of_timespan')]
  end

  def note_of_timespan
    self[Solrizer.solr_name('note_of_timespan')]
  end

  def alternative_numeric_and_or_alphabethic_designation
    self[Solrizer.solr_name('alternative_numeric_and_or_alphabethic_designation')]
  end

  def photographer_corporate_body_of_work
    self[Solrizer.solr_name('photographer_corporate_body_of_work')]
  end

  def dimensions_of_still_image
    self[Solrizer.solr_name('dimensions_of_still_image')]
  end

  def period_of_activity_of_corporate_body
    self[Solrizer.solr_name('period_of_activity_of_corporate_body')]
  end

  def speaker_agent_of
    self[Solrizer.solr_name('speaker_agent_of')]
  end

  def assistant
    self[Solrizer.solr_name('assistant')]
  end

  def preceded_by_work
    self[Solrizer.solr_name('preceded_by_work')]
  end

  def primary_topic
    self[Solrizer.solr_name('primary_topic')]
  end

  def enacting_juridiction_of
    self[Solrizer.solr_name('enacting_juridiction_of')]
  end

  def hierarchical_superior
    self[Solrizer.solr_name('hierarchical_superior')]
  end

  def hierarchical_inferior
    self[Solrizer.solr_name('hierarchical_inferior')]
  end

  def subject_timespan
    self[Solrizer.solr_name('subject_timespan')]
  end

  def identifier_of_work
    self[Solrizer.solr_name('identifier_of_work')]
  end

  def is_title_of_item_of
    self[Solrizer.solr_name('is_title_of_item_of')]
  end

  def timespan_described_in
    self[Solrizer.solr_name('timespan_described_in')]
  end

  def related_person_of
    self[Solrizer.solr_name('related_person_of')]
  end

  def related_corporate_body_of_timespan
    self[Solrizer.solr_name('related_corporate_body_of_timespan')]
  end

  def related_family_timespan
    self[Solrizer.solr_name('related_family_timespan')]
  end

  def handle
    self[Solrizer.solr_name('handle')]
  end

  def digital_file_characteristics
    self[Solrizer.solr_name('digital_file_characteristics')]
  end

  def has_creator
    self[Solrizer.solr_name('has_creator')]
  end

  def narrator
    self[Solrizer.solr_name('narrator')]
  end

  def writer_of_suplementary_textual_content
    self[Solrizer.solr_name('writer_of_suplementary_textual_content')]
  end

  def organizer
    self[Solrizer.solr_name('organizer')]
  end 

  def has_field_activity_of_agent
    self[Solrizer.solr_name('has_field_activity_of_agent')]
  end

  def place_of_publication
    self[Solrizer.solr_name('place_of_publication')]
  end

  def is_facsimile_of_manifestation_of
    self[Solrizer.solr_name('is_facsimile_of_manifestation_of')]
  end

  def beginning
    self[Solrizer.solr_name('beginning')]
  end

  def ending
    self[Solrizer.solr_name('ending')]
  end

  def date_of_manifestation
    self[Solrizer.solr_name('date_of_manifestation')]
  end

  def resource_access_restrictions
    self[Solrizer.solr_name('resource_access_restrictions')]
  end

  def resource_use_restrictions
    self[Solrizer.solr_name('resource_use_restrictions')]
  end

  def manifestation_access_restrictions
    self[Solrizer.solr_name('manifestation_access_restrictions')]
  end

  def manifestation_use_restrictions
    self[Solrizer.solr_name('manifestation_use_restrictions')]
  end

  def item_access_restrictions
    self[Solrizer.solr_name('item_access_restrictions')]
  end

  def complainant
    self[Solrizer.solr_name('complainant')]
  end

  def contestee
    self[Solrizer.solr_name('contestee')]
  end

  def witness
    self[Solrizer.solr_name('witness')]
  end

  def subject_uniform_title
    self[Solrizer.solr_name('subject_uniform_title')]
  end

  def is_criminal_defendant_person_of
    self[Solrizer.solr_name('is_criminal_defendant_person_of')]
  end

  def is_criminal_defendant_corporate_body_of
    self[Solrizer.solr_name('is_criminal_defendant_corporate_body_of')]
  end

  def has_identifier_for_item
    self[Solrizer.solr_name('has_identifier_for_item')]
  end

  def is_finding_aid_for
    self[Solrizer.solr_name('is_finding_aid_for')]
  end

  def collector_collective_agent
    self[Solrizer.solr_name('collector_collective_agent')]
  end
  
  def thematic_collection
    self[Solrizer.solr_name('thematic_collection')]
  end

  def draftsman
    self[Solrizer.solr_name('draftsman')]
  end

  def related_work_of_work
    self[Solrizer.solr_name('related_work_of_work')] 
  end
  
  def numbering_of_part
    self[Solrizer.solr_name('numbering_of_part')] 
  end

  def has_system_of_organization
    self[Solrizer.solr_name('has_system_of_organization')] 
  end

  def is_subcollection_of
    self[Solrizer.solr_name('is_subcollection_of')] 
  end
end