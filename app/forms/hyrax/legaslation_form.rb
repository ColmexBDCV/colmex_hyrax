# Generated via
#  `rails generate hyrax:work Legaslation`
module Hyrax
  # Generated form for Legaslation
  class LegaslationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Legaslation
    self.terms += AnalyticsTypeOneForm.shared_fields
    self.terms += AnalyticsTypeTwoForm.shared_fields
    self.terms += [:resource_type]
  end
end
