# Generated via
#  `rails generate hyrax:work Thesis`
module Hyrax
  class ThesisPresenter < Hyrax::WorkShowPresenter
    delegate :director, :awards, 
    :academic_degree, :type_of_thesis, :degree_program, :institution,  
    :date_of_presentation_of_the_thesis,
    to: :solr_document

    # This must be included at the end,
    include Hyrax::ConacytPresenter

  end
end

