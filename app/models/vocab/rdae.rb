# frozen_string_literal: true

require 'rdf'

module Vocab
  class RDAE  < RDF::Vocabulary('http://www.rdaregistry.info/Elements/e/#')
    term :award
    term :supplementaryContent
    term :languageOfTheContent
    term :summarizationOfTheContent
    term :illustrativeContent
    term :contentType
    term :noteOnExpression
    term :scale
  end
end
