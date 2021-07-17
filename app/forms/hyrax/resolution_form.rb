# Generated via
#  `rails generate hyrax:work Resolution`
module Hyrax
  # Generated form for Resolution
  class ResolutionForm < Hyrax::Forms::WorkForm
    self.model_class = ::Resolution
    self.terms += LegalDocumentsForm.shared_fields
    self.terms += [:resource_type]
  end
end
