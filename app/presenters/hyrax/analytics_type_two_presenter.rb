module Hyrax
    module AnalyticsTypeTwoPresenter
        delegate :issn, :volume, :number, to: :solr_document
    end
end