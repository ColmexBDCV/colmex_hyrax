# frozen_string_literal: true

require 'rdf'

module Vocab
  class RDAT  < RDF::Vocabulary('http://www.rdaregistry.info/Elements/t/#')
    term :timespan_described_in
    term :related_person_of
    term :related_place_of_timespan
    term :related_corporate_body_of_timespan
    term :related_family_of_timespan
    term :note_of_timespan
  end
end
