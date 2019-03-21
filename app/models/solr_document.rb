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
                         rights:      Solrizer.solr_name('rights_statement'),
                         source:      Solrizer.solr_name('source'),
                         subject:     Solrizer.solr_name('subject'),
                         subject_conacyt:     Solrizer.solr_name('subject_conacyt'),
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

  def summary
    self[Solrizer.solr_name('summary')]
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

  def edition
    self[Solrizer.solr_name('edition')]
  end

  def encoding_format_details
    self[Solrizer.solr_name('encoding_format_details')]
  end

  def file_type_details
    self[Solrizer.solr_name('file_type_details')]
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
  
end
