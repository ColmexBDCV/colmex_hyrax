# frozen_string_literal: true

require 'rdf'

module Vocab
  class RDAA  < RDF::Vocabulary('http://www.rdaregistry.info/Elements/a/#')
    term :authorOf
    term :identifierForThePerson
    term :degreeSupervisorOf
    term :otherPFCWorkOf
    term :isEditorPersonOfTextOf
    term :isCompilerAgentFor
    term :isCommentatorAgentOf
    term :isTranslatorAgentOf
    term :organizerAgentOf
    term :curatorCollectiveAgentOf
    term :ownerAgentOf
    term :custodianAgentOf
    term :interviewerAgentOf
    term :intervieweeAgentOf
    term :organizerCollectiveAgent
    term :photographerAgnteOf
  end
end
