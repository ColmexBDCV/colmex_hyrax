# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  class BookPresenter < Hyrax::WorkShowPresenter
    delegate :corporate_body, :collective_agent, 
    :organizer_author, :place_of_publication, :copyright,
    :title_of_series, :numbering_within_sequence,
    to: :solr_document

    # This must be included at the end,
    include Hyrax::ConacytPresenter
  end
end
