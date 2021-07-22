# Generated via
#  `rails generate hyrax:work Presentation`
module Hyrax
  # Generated form for Presentation
  class PresentationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Presentation
    self.terms += AnalyticsTypeOneForm.shared_fields
    self.terms += [:resource_type]
  end
end
