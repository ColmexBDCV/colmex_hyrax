module Conacyt
  extend ActiveSupport::Concern

    included do
        property :creator_conacyt, predicate: ::RDF::Vocab::MODS.namePrincipal, multiple: true do |index|
            index.type :text
            index.as :stored_searchable
        end

        property :contributor_conacyt, predicate: ::RDF::Vocab::MODS.name, multiple: true do |index|
            index.type :text
            index.as :stored_searchable
        end

        property :subject_conacyt, predicate: ::Vocab::RDAW.intendedAudience, multiple: false do |index|
            index.type :text
            index.as :stored_searchable
        end

        property :pub_conacyt, predicate: ::RDF::Vocab::DC11.type, multiple: false do |index|
            index.type :text
            index.as :stored_searchable
        end
    end
end