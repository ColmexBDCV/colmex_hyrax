class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller

  include BlacklightRangeLimit::ControllerOverride
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior
  include BlacklightOaiProvider::Controller
  # This filter applies the hydra access controls
  before_action :enforce_show_permissions, only: :show

  def self.uploaded_field
    solr_name('system_create', :stored_sortable, type: :date)
  end

  def self.year_field
    solr_name('date_created', :facetable, type: :integer)
  end

  def self.modified_field
    solr_name('system_modified', :stored_sortable, type: :date)
  end

  def self.title_field
    solr_name('title', :facetable, type: :string)
  end

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    config.crawler_detector = ->(req) { req.env['HTTP_USER_AGENT'] =~ /Googlebot/ }

    # Show gallery view
    config.view.gallery.partials = [:index_header, :index]
    # config.view.masonry.partials = [:index]
    # config.view.slideshow.partials = [:index]

    config.oai = {
      provider: {
        repository_name: 'Repositorio Institucional Colmex',
        repository_url: 'http://repositorio.colmex.mx/catalog/oai',
        record_prefix: 'http://repositorio.colmex.mx/',
        admin_email: 'rcuellar@colmex.mx',
      },
      document: {
        limit: 25,            # number of records returned with each request, default: 15
        set_fields: [        # ability to define ListSets, optional, default: nil
          {  label: 'collection', solr_field: 'member_of_collections_ssim' }
        ]
      }
    }  

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    config.search_builder_class = SearchBuilder

       

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: "search",
      rows: 10,
      qf: "title_tesim description_tesim creator_tesim keyword_tesim"
    }

    # solr field configuration for document/show views
    config.index.title_field = solr_name("title", :stored_searchable)
    config.index.display_type_field = solr_name("has_model", :symbol)
    config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    # config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type", limit: 5
    config.add_facet_field solr_name('member_of_collections', :symbol), limit: 5, label: 'Collections'
    config.add_facet_field solr_name("resource_type", :facetable), label: "Resource Type", limit: 5
    config.add_facet_field solr_name("creator", :facetable), limit: 5
    config.add_facet_field solr_name("contributor", :facetable), label: "Contributor", limit: 5
    config.add_facet_field solr_name("center", :facetable), limit: 5
    config.add_facet_field solr_name("director", :facetable), limit: 5
    config.add_facet_field solr_name("editor", :facetable), limit: 5
    config.add_facet_field solr_name("compiler", :facetable), limit: 5
    config.add_facet_field solr_name("commentator", :facetable), limit: 5
    config.add_facet_field solr_name("reviewer", :facetable), limit: 5
    config.add_facet_field solr_name("traslator", :facetable), limit: 5
    config.add_facet_field solr_name("interviewer", :facetable), limit: 5
    config.add_facet_field solr_name("interviewee", :facetable), limit: 5
    config.add_facet_field solr_name("organizer_collective_agent", :facetable), limit: 5
    config.add_facet_field solr_name("place_of_publication", :facetable), limit: 5
    config.add_facet_field solr_name("related_work_of_work", :facetable), limit: 5

    
    config.add_facet_field solr_name("date_created", :facetable) do |field|
      field.label = 'year'
      field.range = true
      field.include_in_advanced_search = false
    end
    
    # config.add_facet_field solr_name("keyword", :facetable), limit: 5
    config.add_facet_field solr_name("subject_work", :facetable), limit: 5
    config.add_facet_field solr_name("subject_person", :facetable), limit: 5
    config.add_facet_field solr_name("subject_corporate", :facetable), limit: 5
    config.add_facet_field solr_name("subject", :facetable), limit: 5
    # config.add_facet_field solr_name("subject_family", :facetable), limit: 5
    config.add_facet_field solr_name("language", :facetable), limit: 5
    config.add_facet_field solr_name("based_near_label", :facetable), limit: 5
    config.add_facet_field solr_name("geographic_coverage", :facetable), limit: 5
    config.add_facet_field solr_name("temporary_coverage", :facetable), limit: 5
    # config.add_facet_field solr_name("publisher", :facetable), limit: 5
    #config.add_facet_field solr_name("file_format", :facetable), limit: 5
    
    # config.add_facet_field solr_name("reviewer", :facetable), limit: 5
    config.add_facet_field solr_name("degree_program", :facetable), limit: 5
    config.add_facet_field solr_name("type_of_illustrations", :facetable), limit: 5
    config.add_facet_field solr_name("contained_in", :facetable), limit: 5

    # config.add_facet_field solr_name("database", :facetable), limit: 5
    config.add_facet_field solr_name("researcher_agent_of", :facetable), limit: 5
    config.add_facet_field solr_name("guide_to_work", :facetable), limit: 5
    config.add_facet_field solr_name("production_method", :facetable), limit: 5
    config.add_facet_field solr_name("longitud_and_latitud", :facetable), limit: 5
    config.add_facet_field solr_name("digital_representation_of_cartographic_content", :facetable), limit: 5
    config.add_facet_field solr_name("related_place_of_timespan", :facetable), limit: 5
    config.add_facet_field solr_name("note_of_timespan", :facetable), limit: 5
    config.add_facet_field solr_name("is_part_or_work", :facetable), limit: 5
    config.add_facet_field solr_name("alternative_numeric_and_or_alphabethic_designation_and_or_alphabethic_designation", :facetable), limit: 5
    # config.add_facet_field solr_name("volume", :facetable), limit: 5
    # config.add_facet_field solr_name("number", :facetable), limit: 5
    config.add_facet_field solr_name("photographer", :facetable), limit: 5
    config.add_facet_field solr_name("narrator", :facetable), limit: 5
    config.add_facet_field solr_name("writer_of_suplementary_textual_content", :facetable), limit: 5
    config.add_facet_field solr_name("photographer_corporate_body_of_work", :facetable), limit: 5
    config.add_facet_field solr_name("dimensions_of_still_image", :facetable), limit: 5
    
    config.add_facet_field solr_name("numbering_of_part", :facetable), limit: 5
    config.add_facet_field solr_name("speaker_agent_of", :facetable), limit: 5
    config.add_facet_field solr_name("assistant", :facetable), limit: 5
    config.add_facet_field solr_name("preceded_by_work", :facetable), limit: 5
    config.add_facet_field solr_name("primary_topic", :facetable), limit: 5
    config.add_facet_field solr_name("enacting_juridiction_of", :facetable), limit: 5
    config.add_facet_field solr_name("hierarchical_superior", :facetable), limit: 5
    config.add_facet_field solr_name("hierarchical_inferior", :facetable), limit: 5
    config.add_facet_field solr_name("subject_timespan", :facetable), limit: 5
    config.add_facet_field solr_name("is_title_of_item_of", :facetable), limit: 5
    config.add_facet_field solr_name("timespan_described_in", :facetable), limit: 5
    config.add_facet_field solr_name("related_person_of", :facetable), limit: 5
    config.add_facet_field solr_name("related_corporate_body_of_timespan", :facetable), limit: 5
    config.add_facet_field solr_name("related_family_timespan", :facetable), limit: 5
    config.add_facet_field solr_name("complainant", :facetable), limit: 5
    config.add_facet_field solr_name("contestee", :facetable), limit: 5
    config.add_facet_field solr_name("witness", :facetable), limit: 5
    config.add_facet_field solr_name("is_criminal_defendant_corporate_body_of", :facetable), limit: 5
    config.add_facet_field solr_name("is_criminal_defendant_person_of", :facetable), limit: 5
    config.add_facet_field solr_name("collector_collective_agent", :facetable), limit: 5   
    config.add_facet_field solr_name("subject_uniform_title", :facetable), limit: 5
    config.add_facet_field solr_name("thematic_collection", :facetable), limit: 5
    config.add_facet_field solr_name("has_system_of_organization", :facetable), limit: 5
    config.add_facet_field solr_name("is_subcollection_of", :facetable), limit: 5
    config.add_facet_field solr_name("depository_collective_agent_of", :facetable), limit: 5
    
    
    
    config.add_facet_field solr_name("beginning", :facetable), limit: 5
    config.add_facet_field solr_name("ending", :facetable), limit: 5


    # The generic_type isn't displayed on the facet list
    # It's used to give a label to the filter that comes from the user profile
    config.add_facet_field solr_name("generic_type", :facetable), if: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    config.add_index_field solr_name("creator", :stored_searchable), itemprop: 'creator', link_to_search: solr_name("creator", :facetable)
    config.add_index_field solr_name("has_creator", :stored_searchable), itemprop: 'creator', link_to_search: solr_name("creator", :facetable)
    config.add_index_field solr_name("contributor", :stored_searchable), itemprop: 'contributor', link_to_search: solr_name("contributor", :facetable)
    config.add_index_field solr_name("description", :stored_searchable), itemprop: 'description', helper_method: :iconify_auto_link
    config.add_index_field solr_name("center", :stored_searchable), link_to_search: solr_name("center", :facetable)
    config.add_index_field solr_name("contained_in", :stored_searchable), link_to_search: solr_name("contained_in", :facetable)
    config.add_index_field solr_name("organizer_collective_agent", :stored_searchable), link_to_search: solr_name("organizer_collective_agent", :facetable)
    config.add_index_field solr_name("handle", :stored_searchable)
    config.add_index_field solr_name("volume", :stored_searchable)
    config.add_index_field solr_name("number", :stored_searchable)
    config.add_index_field solr_name("date_created", :stored_searchable), itemprop: 'dateCreated', link_to_search: solr_name("date_created", :facetable)
    config.add_index_field solr_name("geographic_coverage", :stored_searchable), itemprop: 'geographic_coverage', link_to_search: solr_name("geographic_coverage", :facetable)
    config.add_index_field solr_name("subject_work", :stored_searchable), itemprop: 'about', link_to_search: solr_name("subject_work", :facetable)
    config.add_index_field solr_name("subject_person", :stored_searchable), itemprop: 'about', link_to_search: solr_name("subject_person", :facetable)
    config.add_index_field solr_name("subject_corporate", :stored_searchable), itemprop: 'about', link_to_search: solr_name("subject_corporate", :facetable)
    config.add_index_field solr_name("subject", :stored_searchable), itemprop: 'about', link_to_search: solr_name("subject", :facetable)
    config.add_index_field solr_name("temporary_coverage", :stored_searchable), itemprop: 'temporary_coverage', link_to_search: solr_name("temporary_coverage", :facetable)
    config.add_index_field solr_name("resource_type", :stored_searchable), label: "Resource Type", link_to_search: solr_name("resource_type", :facetable)
    config.add_index_field solr_name("type_of_illustrations", :stored_searchable), link_to_search: solr_name("type_of_illustrations", :facetable)
    config.add_index_field solr_name("classification", :stored_searchable)
    config.add_index_field solr_name("pages", :stored_searchable)
    config.add_index_field solr_name("thematic_collection", :stored_searchable), link_to_search: solr_name("thematic_collection", :facetable)
    config.add_index_field solr_name("related_url", :stored_searchable), helper_method: :link_to_url 
    # config.add_index_field solr_name("identifier", :stored_searchable), helper_method: :link_to_alma, field_name: 'identifier'
    config.add_index_field solr_name("director", :stored_searchable), link_to_search: solr_name("director", :facetable)
    config.add_index_field solr_name("mode_of_issuance", :stored_searchable)
    config.add_index_field solr_name("degree_program", :stored_searchable), link_to_search: solr_name("degree_program", :facetable)
    # config.add_index_field solr_name("database", :stored_searchable), link_to_search: solr_name("database", :facetable)
    config.add_index_field solr_name("alternative_numeric_and_or_alphabethic_designation", :stored_searchable), link_to_search: solr_name("alternative_numeric_and_or_alphabethic_designation", :facetable)
    # config.add_index_field solr_name("keyword", :stored_searchable), itemprop: 'keywords', link_to_search: solr_name("keyword", :facetable)
    # config.add_index_field solr_name("subject_family", :stored_searchable), itemprop: 'about', link_to_search: solr_name("subject_family", :facetable)
    config.add_index_field solr_name("proxy_depositor", :symbol), label: "Depositor", helper_method: :link_to_profile
    # config.add_index_field solr_name("depositor"), label: "Owner", helper_method: :link_to_profile
    # config.add_index_field solr_name("publisher", :stored_searchable), itemprop: 'publisher', link_to_search: solr_name("publisher", :facetable)
    config.add_index_field solr_name("based_near_label", :stored_searchable), itemprop: 'contentLocation', link_to_search: solr_name("based_near_label", :facetable)
    config.add_index_field solr_name("language", :stored_searchable), itemprop: 'inLanguage', link_to_search: solr_name("language", :facetable)
    # config.add_index_field solr_name("date_uploaded", :stored_sortable, type: :date), itemprop: 'datePublished', helper_method: :human_readable_date
    # config.add_index_field solr_name("date_modified", :stored_sortable, type: :date), itemprop: 'dateModified', helper_method: :human_readable_date
    # config.add_index_field solr_name("rights_statement", :stored_searchable), helper_method: :rights_statement_links
    # config.add_index_field solr_name("license", :stored_searchable), helper_method: :license_links
    config.add_index_field solr_name("file_format", :stored_searchable), link_to_search: solr_name("file_format", :facetable)
    config.add_index_field solr_name("embargo_release_date", :stored_sortable, type: :date), label: "Embargo release date", helper_method: :human_readable_date
    config.add_index_field solr_name("lease_expiration_date", :stored_sortable, type: :date), label: "Lease expiration date", helper_method: :human_readable_date
    config.add_index_field solr_name("corporate_body", :stored_searchable)
    config.add_index_field solr_name("collective_agent", :stored_searchable)
    config.add_index_field solr_name("related_work_of_work", :stored_searchable)
    config.add_index_field solr_name("numbering_of_part", :stored_searchable)
    config.add_index_field solr_name("organizer_author", :stored_searchable)
    config.add_index_field solr_name("copyright", :stored_searchable)
    config.add_index_field solr_name("title_of_series", :stored_searchable)
    config.add_index_field solr_name("numbering_within_sequence", :stored_searchable)
    config.add_index_field solr_name("video_format", :stored_searchable)
    config.add_index_field solr_name("video_characteristic", :stored_searchable)
    config.add_index_field solr_name("note_on_statement_of_responsibility", :stored_searchable)
    config.add_index_field solr_name("editor", :stored_searchable), link_to_search: solr_name("editor", :facetable)
    config.add_index_field solr_name("compiler", :stored_searchable), link_to_search: solr_name("compiler", :facetable)
    config.add_index_field solr_name("commentator", :stored_searchable), link_to_search: solr_name("commentator", :facetable)
    config.add_index_field solr_name("reviewer", :stored_searchable), link_to_search: solr_name("reviewer", :facetable)
    config.add_index_field solr_name("traslator", :stored_searchable), link_to_search: solr_name("traslator", :facetable)
    config.add_index_field solr_name("interviewer", :stored_searchable)
    config.add_index_field solr_name("interviewee", :stored_searchable)
    config.add_index_field solr_name("photographer", :stored_searchable)
    config.add_index_field solr_name("narrator", :stored_searchable)
    config.add_index_field solr_name("writer_of_suplementary_textual_content", :stored_searchable)
    config.add_index_field solr_name("collective_title", :stored_searchable)
    config.add_index_field solr_name("part_of_place", :stored_searchable)
    config.add_index_field solr_name("provenance", :stored_searchable)
    config.add_index_field solr_name("curator_collective_agent_of", :stored_searchable)
    config.add_index_field solr_name("project", :stored_searchable)
    config.add_index_field solr_name("owner_agent_of", :stored_searchable)
    config.add_index_field solr_name("custodian_agent_of", :stored_searchable)
    config.add_index_field solr_name("file_type_details", :stored_searchable)
    config.add_index_field solr_name("depository_collective_agent_of", :stored_searchable)
    config.add_index_field solr_name("depository_agent", :stored_searchable)
    config.add_index_field solr_name("is_part_or_work", :stored_searchable), link_to_search: solr_name("is_part_or_work", :facetable)
    config.add_index_field solr_name("issn", :stored_searchable)
    config.add_index_field solr_name("is_lyricist_person_of", :stored_searchable)
    config.add_index_field solr_name("is_composer_person_of", :stored_searchable)
    config.add_index_field solr_name("researcher_agent_of", :stored_searchable)
    config.add_index_field solr_name("summary_of_work", :stored_searchable)
    config.add_index_field solr_name("nature_of_content", :stored_searchable)
    config.add_index_field solr_name("guide_to_work", :stored_searchable)
    config.add_index_field solr_name("analysis_of_work", :stored_searchable)
    config.add_index_field solr_name("complemented_by_work", :stored_searchable)
    config.add_index_field solr_name("production_method", :stored_searchable)
    config.add_index_field solr_name("scale", :stored_searchable)
    config.add_index_field solr_name("longitud_and_latitud", :stored_searchable)
    config.add_index_field solr_name("digital_representation_of_cartographic_content", :stored_searchable), itemprop: 'digital_representation_of_cartographic_content', link_to_search: solr_name("digital_representation_of_cartographic_content", :facetable)
    config.add_index_field solr_name("related_place_of_timespan", :stored_searchable), itemprop: 'related_place_of_timespan', link_to_search: solr_name("related_place_of_timespan", :facetable)
    config.add_index_field solr_name("note_of_timespan", :stored_searchable), itemprop: 'note_of_timespan', link_to_search: solr_name("note_of_timespan", :facetable)
    config.add_index_field solr_name("photographer_corporate_body_of_work", :stored_searchable), itemprop: 'photographer_corporate_body_of_work', link_to_search: solr_name("photographer_corporate_body_of_work", :facetable)
    config.add_index_field solr_name("dimensions_of_still_image", :stored_searchable), itemprop: 'dimensions_of_still_image', link_to_search: solr_name("dimensions_of_still_image", :facetable)
    config.add_index_field solr_name("period_of_activity_of_corporate_body", :stored_searchable)
    config.add_index_field solr_name("speaker_agent_of", :stored_searchable), itemprop: 'speaker_agent_of', link_to_search: solr_name("speaker_agent_of", :facetable)
    config.add_index_field solr_name("assistant", :stored_searchable), itemprop: 'assistant', link_to_search: solr_name("assistant", :facetable)
    config.add_index_field solr_name("preceded_by_work", :stored_searchable), itemprop: 'preceded_by_work', link_to_search: solr_name("preceded_by_work", :facetable)
    config.add_index_field solr_name("primary_topic", :stored_searchable), itemprop: 'primary_topic', link_to_search: solr_name("primary_topic", :facetable)
    config.add_index_field solr_name("enacting_juridiction_of", :stored_searchable), itemprop: 'enacting_juridiction_of', link_to_search: solr_name("enacting_juridiction_of", :facetable)
    config.add_index_field solr_name("hierarchical_superior", :stored_searchable), itemprop: 'hierarchical_superior', link_to_search: solr_name("hierarchical_superior", :facetable)
    config.add_index_field solr_name("hierarchical_inferior", :stored_searchable), itemprop: 'hierarchical_inferior', link_to_search: solr_name("hierarchical_inferior", :facetable)
    config.add_index_field solr_name("subject_timespan", :stored_searchable), itemprop: 'subject_timespan', link_to_search: solr_name("subject_timespan", :facetable)
    config.add_index_field solr_name("identifier_of_work", :stored_searchable)
    config.add_index_field solr_name("is_title_of_item_of", :stored_searchable), itemprop: 'is_title_of_item_of', link_to_search: solr_name("is_title_of_item_of", :facetable)
    config.add_index_field solr_name("timespan_described_in", :stored_searchable), itemprop: 'timespan_described_in', link_to_search: solr_name("timespan_described_in", :facetable)
    config.add_index_field solr_name("related_person_of", :stored_searchable), itemprop: 'related_person_of', link_to_search: solr_name("related_person_of", :facetable)
    config.add_index_field solr_name("related_corporate_body_of_timespan", :stored_searchable), itemprop: 'related_corporate_body_of_timespan', link_to_search: solr_name("related_corporate_body_of_timespan", :facetable)
    config.add_index_field solr_name("related_family_timespan", :stored_searchable), itemprop: 'related_family_timespan', link_to_search: solr_name("related_family_timespan", :facetable)
    config.add_index_field solr_name("complainant", :stored_searchable), itemprop: 'complainant', link_to_search: solr_name("complainant", :facetable)
    config.add_index_field solr_name("contestee", :stored_searchable), itemprop: 'contestee', link_to_search: solr_name("contestee", :facetable)
    config.add_index_field solr_name("witness", :stored_searchable), itemprop: 'witness', link_to_search: solr_name("witness", :facetable)
    config.add_index_field solr_name("is_criminal_defendant_corporate_body_of", :stored_searchable), itemprop: 'is_criminal_defendant_corporate_body_of', link_to_search: solr_name("is_criminal_defendant_corporate_body_of", :facetable)
    config.add_index_field solr_name("is_criminal_defendant_person_of", :stored_searchable), itemprop: 'is_criminal_defendant_person_of', link_to_search: solr_name("is_criminal_defendant_person_of", :facetable)
    config.add_index_field solr_name("has_identifier_for_item", :stored_searchable)
    config.add_index_field solr_name("place_of_publication", :stored_searchable), itemprop: 'place_of_publication', link_to_search: solr_name("place_of_publication", :facetable)
    config.add_index_field solr_name("beginning", :stored_searchable), itemprop: 'beginning', link_to_search: solr_name("beginning", :facetable)
    config.add_index_field solr_name("ending", :stored_searchable), itemprop: 'ending', link_to_search: solr_name("ending", :facetable)
    config.add_index_field solr_name("has_field_activity_of_agent", :stored_searchable)
    config.add_index_field solr_name("is_facsimile_of_manifestation_of", :stored_searchable)
    config.add_index_field solr_name("date_of_manifestation", :stored_searchable)
    config.add_index_field solr_name("is_finding_aid_for", :stored_searchable)
    config.add_index_field solr_name("collector_collective_agent", :stored_searchable), itemprop: 'collector_collective_agent', link_to_search: solr_name("collector_collective_agent", :facetable)
    config.add_index_field solr_name("subject_uniform_title", :stored_searchable), itemprop: 'subject_uniform_title', link_to_search: solr_name("subject_uniform_title", :facetable)

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name("title", :stored_searchable)
    config.add_show_field solr_name("description", :stored_searchable)
    config.add_show_field solr_name("keyword", :stored_searchable)
    config.add_show_field solr_name("subject", :stored_searchable)
    config.add_show_field solr_name("creator", :stored_searchable)
    config.add_show_field solr_name("contributor", :stored_searchable)
    config.add_show_field solr_name("publisher", :stored_searchable)
    config.add_show_field solr_name("based_near_label", :stored_searchable)
    config.add_show_field solr_name("language", :stored_searchable)
    config.add_show_field solr_name("date_uploaded", :stored_searchable)
    config.add_show_field solr_name("date_modified", :stored_searchable)
    config.add_show_field solr_name("date_created", :stored_searchable)
    config.add_show_field solr_name("rights_statement", :stored_searchable)
    config.add_show_field solr_name("license", :stored_searchable)
    config.add_show_field solr_name("resource_type", :stored_searchable), label: "Resource Type"
    config.add_show_field solr_name("format", :stored_searchable)
    config.add_show_field solr_name("identifier", :stored_searchable)
    config.add_show_field solr_name("interviewer", :stored_searchable)

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      field.advanced_parse = false	
      all_names = config.show_fields.values.map(&:field).join(" ")
      title_name = solr_name("title", :stored_searchable)
      field.solr_parameters = {
        qf: "#{all_names} file_format_tesim all_text_timv director_tesim subject_work_tesim subject_person_tesim subject_corporate_tesim geographic_coverage_tesim temporary_coverage_tesim table_of_contents_tesim",
        pf: title_name.to_s
      }
    end

    config.add_search_field('title') do |field|
      solr_name = solr_name("title", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('creator') do |field|
      solr_name = solr_name("creator", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    # creator, title, description, publisher, date_created,
    # subject, language, resource_type, format, identifier, based_near,
    config.add_search_field('contributor') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      solr_name = solr_name("contributor", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('description') do |field|
      field.label = "Abstract or Summary"
      solr_name = solr_name("description", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('publisher') do |field|
      solr_name = solr_name("publisher", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('date_created') do |field|
      solr_name = solr_name("created", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('subject_work') do |field|
      solr_name = solr_name("subject_work", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('subject_person') do |field|
      solr_name = solr_name("subject_person", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('subject_corporate') do |field|
      solr_name = solr_name("subject_corporate", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('subject') do |field|
      solr_name = solr_name("subject", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('geographic_coverage') do |field|
      solr_name = solr_name("geographic_coverage", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('temporary_coverage') do |field|
      solr_name = solr_name("temporary_coverage", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end 

    config.add_search_field('director') do |field|
      solr_name = solr_name("director", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('degree_program') do |field|
      solr_name = solr_name("degree_program", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    # config.add_search_field('language') do |field|
    #   solr_name = solr_name("language", :stored_searchable)
    #   field.solr_local_parameters = {
    #     qf: solr_name,
    #     pf: solr_name
    #   }
    # end

    # config.add_search_field('resource_type') do |field|
    #   solr_name = solr_name("resource_type", :stored_searchable)
    #   field.solr_local_parameters = {
    #     qf: solr_name,
    #     pf: solr_name
    #   }
    # end

    # config.add_search_field('format') do |field|
    #   solr_name = solr_name("format", :stored_searchable)
    #   field.solr_local_parameters = {
    #     qf: solr_name,
    #     pf: solr_name
    #   }
    # end

    # config.add_search_field('identifier') do |field|
    #   solr_name = solr_name("id", :stored_searchable)
    #   field.solr_local_parameters = {
    #     qf: solr_name,
    #     pf: solr_name
    #   }
    # end

    # config.add_search_field('based_near') do |field|
    #   field.label = "Location"
    #   solr_name = solr_name("based_near_label", :stored_searchable)
    #   field.solr_local_parameters = {
    #     qf: solr_name,
    #     pf: solr_name
    #   }
    # end

    # config.add_search_field('keyword') do |field|
    #   solr_name = solr_name("keyword", :stored_searchable)
    #   field.solr_local_parameters = {
    #     qf: solr_name,
    #     pf: solr_name
    #   }
    # end

    # config.add_search_field('depositor') do |field|
    #   solr_name = solr_name("depositor", :symbol)
    #   field.solr_local_parameters = {
    #     qf: solr_name,
    #     pf: solr_name
    #   }
    # end

    # config.add_search_field('rights_statement') do |field|
    #   solr_name = solr_name("rights_statement", :stored_searchable)
    #   field.solr_local_parameters = {
    #     qf: solr_name,
    #     pf: solr_name
    #   }
    # end

    # config.add_search_field('license') do |field|
    #   solr_name = solr_name("license", :stored_searchable)
    #   field.solr_local_parameters = {
    #     qf: solr_name,
    #     pf: solr_name
    #   }
    # end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, #{uploaded_field} desc", label: "relevance"
    config.add_sort_field "#{uploaded_field} desc", label: "date uploaded \u25BC"
    config.add_sort_field "#{uploaded_field} asc", label: "date uploaded \u25B2"
    config.add_sort_field "#{year_field} desc", label: "date created \u25BC"
    config.add_sort_field "#{year_field} asc", label: "date created \u25B2"
    # config.add_sort_field "#{modified_field} desc", label: "date modified \u25BC"
    # config.add_sort_field "#{modified_field} asc", label: "date modified \u25B2"
    config.add_sort_field "#{title_field} asc", label: 'Title [A-Z]'
    config.add_sort_field "#{title_field} desc", label: 'Title [Z-A]'


    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  # disable the bookmark control from displaying in gallery view
  # Hyrax doesn't show any of the default controls on the list view, so
  # this method is not called in that context.
  def render_bookmarks_control?
    false
  end
end