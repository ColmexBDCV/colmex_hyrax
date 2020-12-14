module ArticlesAndChapters
    extend ActiveSupport::Concern
  
      included do
         
        property :contained_in, predicate: ::Vocab::RDAW.containedWork, multiple: true do |index|
          index.type :text
          index.as :stored_searchable, :facetable
        end

        property :database, predicate: ::Vocab::RDAZ.sourceConsulted, multiple: true do |index|
          index.type :text
          index.as :stored_searchable, :facetable
        end

        property :is_part_or_work, predicate: ::Vocab::RDAZ.hasRelatedWorkOfWork, multiple: true do |index|
          index.type :text
          index.as :stored_searchable, :facetable
        end

      end
  end