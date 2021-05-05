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
    term :isWriterOfSuplementaryTextualContent
    term :isOrganizerCollectiveAgentOf
    term :enacting_juridiction_of
    term :PhotographerCorporateBodyOfWork
    term :hierarchical_superior
    term :hierarchical_inferior
    term :period_of_activity_of_corporate_body
    term :speaker_agent_of
    term :assistant
    term :criminalDefendantCorporateBodyOf
    term :criminalDefendantPersonOf
    term :researcher_agent_of
    term :isLyricistPersonOf
    term :isComposerPersonOf

  end
end
