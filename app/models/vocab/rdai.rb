# frozen_string_literal: true

require 'rdf'

module Vocab
  class RDAI  < RDF::Vocabulary('http://www.rdaregistry.info/Elements/i/#')
    term :restrictionsOnAccessToItem
    term :restrictionsOnUseOfItem
    term :depositoryCollectiveAgent
    term :depositoryAgent
  end
end
