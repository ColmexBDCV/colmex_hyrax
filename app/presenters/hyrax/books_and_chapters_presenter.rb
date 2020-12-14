module Hyrax
    module BooksAndChaptersPresenter
        delegate :organizer_author, :place_of_publication, :copyright, :title_of_series, :numbering_within_sequence, to: :solr_document
    end
end