# Generated via
#  `rails generate hyrax:work Thesis`
module Hyrax
  class ThesisPresenter < Hyrax::WorkShowPresenter
    delegate :director, :reviewer, :awards,  
    :item_access_restrictions, :item_use_restrictions, 
    :edition, :encoding_format_details, :file_type_details, :digital_resource_generation_information, 
    :file_details, :dimensions, :system_requirements, :exemplar_of_manifestation, :extension, :type_of_file, 
    :mode_of_publication, :other_formats, :access_restrictions, :use_restrictions, 
    :academic_degree, :type_of_thesis, :degree_program, :institution,
    #:date_of_presentation_of_the_thesis, 
    to: :solr_document

    # This must be included at the end,
    include Hyrax::ConacytPresenter

  end
end
