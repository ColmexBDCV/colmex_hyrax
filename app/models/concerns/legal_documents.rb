module LegalDocuments
    extend ActiveSupport::Concern
  
    included do
      property :primary_topic, predicate: ::RDF::Vocab::FOAF.isPrimaryTopicOf, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 
      
      property :enacting_juridiction_of, predicate: ::Vocab::RDAA.enactingJuridictionOf, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

      property :hierarchical_superior, predicate: ::Vocab::RDAA.hierarchicalSuperior, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

      property :hierarchical_inferior, predicate: ::Vocab::RDAA.hierarchicalInferior, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 
      
      property :subject_timespan, predicate: ::Vocab::RDAW.subjectTimeSpan, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

      property :identifier_of_work, predicate: ::Vocab::RDAW.identifierOfWork, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

      property :is_title_of_item_of, predicate: ::Vocab::RDAN.isTitleOfItemOf, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 
      
      property :timespan_described_in, predicate: ::Vocab::RDAT.timespanDescribedIn, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

      property :related_person_of, predicate: ::Vocab::RDAT.relatedPersonOf, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

      property :related_corporate_body_of_timespan, predicate: ::Vocab::RDAT.relatedCorporateBodyOfTimespan, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 
      
      property :related_family_timespan, predicate: ::Vocab::RDAT.relatedFamilyOfTimespan, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

      property :complainant, predicate: ::RDF::Vocab::MARCRelators.cpl, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 
      
      property :contestee, predicate: ::RDF::Vocab::MARCRelators.cts, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

      property :witness, predicate: ::RDF::Vocab::MARCRelators.wit, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

      property :is_criminal_defendant_corporate_body_of, predicate: ::Vocab::RDAA.isCriminalDefendantCorporateBodyOf, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

      property :is_criminal_defendant_person_of, predicate: ::Vocab::RDAA.isCriminalDefendantPersonOf, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

      property :has_identifier_for_item, predicate: ::Vocab::RDAI.hasIdentifierForItem, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

    end
end