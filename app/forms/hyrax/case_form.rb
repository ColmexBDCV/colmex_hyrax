# Generated via
#  `rails generate hyrax:work Case`
module Hyrax
  # Generated form for Case
  class CaseForm < Hyrax::Forms::WorkForm
    self.model_class = ::Case
    self.terms += LegalDocumentsForm.shared_fields
    self.terms += [:resource_type]
  end
end
