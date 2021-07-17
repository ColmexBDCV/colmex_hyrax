# Generated via
#  `rails generate hyrax:work Amparo`
module Hyrax
  # Generated form for Amparo
  class AmparoForm < Hyrax::Forms::WorkForm
    self.model_class = ::Amparo
    self.terms += LegalDocumentsForm.shared_fields
    self.terms += [:resource_type]
  end
end
