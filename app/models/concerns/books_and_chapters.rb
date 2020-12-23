module BooksAndChapters
    extend ActiveSupport::Concern
  
    included do
         
      property :organizer_author, predicate: ::Vocab::RDAA.organizerAgentOf, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 
    
      property :place_of_publication, predicate: ::Vocab::RDAM.placeOfPublication, multiple: true do |index|
        index.type :text
        index.as :stored_searchable, :facetable
      end 
    
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