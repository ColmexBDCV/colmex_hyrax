module Hyrax
    module AnalyticsTypeOnePresenter
        delegate :alternative_numeric_and_or_alphabethic_designation, :is_part_or_work,  to: :solr_document
    end
end