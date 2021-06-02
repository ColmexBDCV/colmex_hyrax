module AnalyticsTypeTwo
    extend ActiveSupport::Concern
  
    included do
               
      property :period, predicate: ::Vocab::RDAM.alternativeNumericAndOrAlphabeticDesignationOfLastIssueOrPartOfSequence, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end

      property :issn, predicate: ::Vocab::RDAM.issnOfSeries, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end
      
      property :volume, predicate: ::Vocab::RDAM.numberingOfSerials, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 
    
      property :number, predicate: ::Vocab::RDAM.numberingWithinSubseries, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 


    end
end