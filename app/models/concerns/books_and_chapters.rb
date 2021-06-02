module BooksAndChapters
    extend ActiveSupport::Concern
  
    included do
      property :copyright, predicate: ::Vocab::RDAM.copyrightDate, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 
      
      property :title_of_series, predicate: ::Vocab::RDAM.titleOfSeries, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 

      property :numbering_within_sequence, predicate: ::Vocab::RDAM.numberingOfSequence, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 
    end
end
