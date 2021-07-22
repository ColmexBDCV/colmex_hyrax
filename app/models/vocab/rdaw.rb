# frozen_string_literal: true

require 'rdf'

module Vocab
  class RDAW  < RDF::Vocabulary('http://www.rdaregistry.info/Elements/w/#')
    term :intendedAudience
    term :subjectRelationship
    term :coverageOfTheContent
    term :formOfWork
    term :academicDegree
    term :grantingInstitutionOrFaculty
    term :academicDegree
    term :wholePartWorkRelationship
    term :subjectPerson
    term :subjectFamily
    term :subjectWork
    term :subjectCorporateBody
    term :yearDegreeGranted
    term :dissertationOrThesisInformation
    term :containedInWork
    term :numberingOfPart
    term :hasRelatedWorkOfWork
    term :identifierOfWork
    term :hasRelatedWorkOfWork
    term :precededByWork
    term :subjectTimeSpan
    term :summaryOfWork
    term :natureOfContent
    term :guideToWork
    term :analysisOfWork
    term :complementedByWork
    term :subjectUniformTitle
  end
end
