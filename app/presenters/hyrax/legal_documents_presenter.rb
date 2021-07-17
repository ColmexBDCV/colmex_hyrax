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
        :related_family_timespan,
        :complainant,
        :contestee,
        :witness,
        :is_criminal_defendant_corporate_body_of,
        :is_criminal_defendant_person_of,
        :has_identifier_for_item, to: :solr_document
    end
end