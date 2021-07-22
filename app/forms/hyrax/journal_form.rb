# Generated via
#  `rails generate hyrax:work Journal`
module Hyrax
  # Generated form for Journal
  class JournalForm < Hyrax::Forms::WorkForm
    self.model_class = ::Journal
    self.terms += AnalyticsTypeTwoForm.shared_fields
    self.terms += [:resource_type]
  end
end
