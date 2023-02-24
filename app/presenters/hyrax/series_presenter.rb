module Hyrax
    module SeriesPresenter
        delegate :copyright, :title_of_series, :numbering_within_sequence, to: :solr_document
    end
end