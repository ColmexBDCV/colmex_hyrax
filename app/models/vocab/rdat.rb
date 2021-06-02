# frozen_string_literal: true

require 'rdf'

module Vocab
  class RDAT  < RDF::Vocabulary('http://www.rdaregistry.info/Elements/t/#')
    term :timespanDescribedIn
    term :relatedPersonOf
    term :relatedPlaceOfTimespan
    term :relatedCcorporateBodyOfTimespan
    term :relatedFamilyOfTimespan
    term :noteOfTimespan
    term :hasBeginning
    term :hasEnding

  end
end
