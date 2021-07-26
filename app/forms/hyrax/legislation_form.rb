# Generated via
#  `rails generate hyrax:work Legislation`
module Hyrax
  # Generated form for Legislation
  class LegislationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Legislation
    self.terms += AnalyticsTypeOneForm.shared_fields
    self.terms += AnalyticsTypeTwoForm.shared_fields
    self.terms += [:resource_type]
  end
end
