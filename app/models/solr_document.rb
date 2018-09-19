# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocument

  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  field_semantics.merge!(
                        #  contributor: Solrizer.solr_name('contributor'),
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
                         rights:      Solrizer.solr_name('rights'),
                        #  source:      Solrizer.solr_name('source'),
                        #  subject:     Solrizer.solr_name('subject'),
                         alternate_title: Solrizer.solr_name('alternate_title'),
                         other_title: Solrizer.solr_name('other_title'),
                         subject_person: Solrizer.solr_name('subject_person'),
                         subject_family: Solrizer.solr_name('subject_family'),
                         subject_work: Solrizer.solr_name('subject_work'),
                         subject_topic: Solrizer.solr_name('subject_topic'),
                         subject_conacyt:     Solrizer.solr_name('subject_conacyt'),
                         title:       Solrizer.solr_name('title'),
                         type:        Solrizer.solr_name('resource_type'),
                         access: Solrizer.solr_name('access'))

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

  def temporary_coverage
    self[Solrizer.solr_name('temporary_coverage')]
  end

  def subject_conacyt
    self[Solrizer.solr_name('subject_conacyt')]
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

  def subject_topic
    self[Solrizer.solr_name('subject_topic')]
  end

  def alternate_title
    self[Solrizer.solr_name('alternate_title')]
  end
 
  def creator_conacyt
    self[Solrizer.solr_name('creator_conacyt')]
  end

end
