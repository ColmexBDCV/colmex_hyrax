# frozen_string_literal: true

require 'rdf'

module Vocab
  class RDAZ  < RDF::Vocabulary('http://www.rdaregistry.info/Elements/z/#')
    term :sourceConsulted
  end
end