# Generated via
#  `rails generate hyrax:work Request`
module Hyrax
  # Generated form for Request
  class RequestForm < Hyrax::Forms::WorkForm
    self.model_class = ::Request
    self.terms += LegalDocumentsForm.shared_fields
    self.terms += [:resource_type]
  end
end
