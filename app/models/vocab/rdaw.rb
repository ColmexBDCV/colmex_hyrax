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
  end
end
