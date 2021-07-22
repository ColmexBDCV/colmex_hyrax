# Generated via
#  `rails generate hyrax:work LegalCase`
module Hyrax
  # Generated form for LegalCase
  class LegalCaseForm < Hyrax::Forms::WorkForm
    self.model_class = ::LegalCase
    self.terms += LegalDocumentsForm.shared_fields
    self.terms += [:resource_type]
  end
end
