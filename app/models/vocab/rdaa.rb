# frozen_string_literal: true

require 'rdf'

module Vocab
  class RDAA  < RDF::Vocabulary('http://www.rdaregistry.info/Elements/a/#')
    term :authorOf
    term :identifierForThePerson
    term :degreeSupervisorOf
    term :otherPFCWorkOf
  end
end