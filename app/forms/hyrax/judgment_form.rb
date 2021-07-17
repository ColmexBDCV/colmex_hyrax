# Generated via
#  `rails generate hyrax:work Judgment`
module Hyrax
  # Generated form for Judgment
  class JudgmentForm < Hyrax::Forms::WorkForm
    self.model_class = ::Judgment
    self.terms += LegalDocumentsForm.shared_fields
    self.terms += [:resource_type]
  end
end
