# frozen_string_literal: true

require 'rdf'

module Vocab
  class RDAN  < RDF::Vocabulary('http://www.rdaregistry.info/Elements/n/#')
    term :isTitleOfItemOf
  end
end