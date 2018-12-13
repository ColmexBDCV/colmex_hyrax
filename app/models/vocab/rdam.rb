# frozen_string_literal: true

require 'rdf'

module Vocab
  class RDAM  < RDF::Vocabulary('http://www.rdaregistry.info/Elements/m/#')
    term :preferredCitation
    term :fileType
    term :identifierForTheManifestation
    term :otherTitleInformation
    term :titleProper
    term :variantTitle
    term :dateOfPublication
    term :relatedManifestation
    term :modeOfIssuance
    term :digitalFileCharacteristic
    term :exemplarOfManifestation
    term :statementOfResponsibilityRelatingToTitleProper
    term :publicationStatement
    term :designationOfEdition
    term :noteOnManifestation
    term :equipmentOrSystemRequirement
    term :extent
    term :dimensions
    term :detailsOfEncodingFormat
    term :detailsOfFileType
    term :detailsOfGenerationOfDigitalResource
    term :restrictionsOnAccessToManifestation
    term :restrictionsOnUseOfManifestation
    term :alternativeNumericAndOrAlphabeticDesignationOfLastIssueOrPartOfSequence
    term :alternativeNumericAndOrAlphabeticDesignationOfFirstIssueOrPartOfSequence
    term :chronologicalDesignationOfFirstIssueOrPartOfSequence
    term :numberingOfSerials
    term :numberingWithinSubseries
  end
end
