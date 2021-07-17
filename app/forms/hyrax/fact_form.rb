# Generated via
#  `rails generate hyrax:work Fact`
module Hyrax
  # Generated form for Fact
  class FactForm < Hyrax::Forms::WorkForm
    self.model_class = ::Fact
    self.terms += LegalDocumentsForm.shared_fields
    self.terms += [:resource_type, :related_place_of_timespan, :note_of_timespan]
  end
end
