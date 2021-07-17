# Generated via
#  `rails generate hyrax:work Recomendation`
module Hyrax
  # Generated form for Recomendation
  class RecomendationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Recomendation
    self.terms += LegalDocumentsForm.shared_fields
    self.terms += [:resource_type]
  end
end
