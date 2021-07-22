# Generated via
#  `rails generate hyrax:work PressRelease`
module Hyrax
  # Generated form for PressRelease
  class PressReleaseForm < Hyrax::Forms::WorkForm
    self.model_class = ::PressRelease
    self.terms += AnalyticsTypeOneForm.shared_fields
    self.terms += AnalyticsTypeTwoForm.shared_fields
    self.terms += [:resource_type]
  end
end
