module AnalyticsTypeOne
    extend ActiveSupport::Concern
  
      included do
         
        property :is_part_or_work, predicate: ::Vocab::RDAZ.hasRelatedWorkOfWork, multiple: true do |index|
          index.type :text
          index.as :stored_searchable, :facetable
        end

        property :alternative_numeric_and_or_alphabethic_designation, predicate: ::Vocab::RDAM.alternativeNumericAndOrAlphabeticDesignationOfFirstIssueOrPartOfSequence, multiple: true do |index|
          index.type :text
          index.as :stored_searchable, :facetable
        end
      end
  end