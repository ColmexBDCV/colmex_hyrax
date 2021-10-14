# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  # Generated form for Article
  class ArticleForm < Hyrax::Forms::WorkForm
    self.model_class = ::Article
    self.terms += [:resource_type]
    self.terms += AnalyticsTypeOneForm.shared_fields
    self.terms += AnalyticsTypeTwoForm.shared_fields
    # This must be included at the end,
    self.terms += ConacytForm.special_fields
  end
end
