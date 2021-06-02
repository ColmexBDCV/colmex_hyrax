module Hyrax
    module LegalDocumentsPresenter
        delegate :primary_topic, :enacting_juridiction_of,
        :hierarchical_superior, :hierarchical_inferior, 
        :subject_timespan,
        :identifier_of_work,
        :is_title_of_item_of,
        :timespan_described_in,
        :related_person_of,
        :related_corporate_body_of_timespan,
        :related_family_timespan, to: :solr_document
    end
end