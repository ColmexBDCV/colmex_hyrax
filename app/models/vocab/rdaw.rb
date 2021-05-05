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
    term :identifier_of_work
    term :has_related_work_of_work
    term :preceded_by_work
    term :subjectTimeSpan
    term :summary_of_work
    term :nature_of_content
    term :guide_to_work
    term :analysis_of_work
    term :complemented_by_work
  end
end
