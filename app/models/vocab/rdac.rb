# frozen_string_literal: true

require 'rdf'

module Vocab
  class RDAC  < RDF::Vocabulary('http://www.rdaregistry.info/Elements/c/#')
    term :corporateBody
    term :collectiveAgent
    term :partOfPlace
  end
end
