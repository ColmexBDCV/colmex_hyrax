# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  # Generated form for Article
  class ArticleForm < Hyrax::Forms::WorkForm
    self.model_class = ::Article
    self.terms += [:resource_type, :period, :part, :year, :volume, :number, :mode_of_issuance, :pages, :contained_in]
     # This must be included at the end,
      self.terms += ConacytForm.special_fields
  end
end
