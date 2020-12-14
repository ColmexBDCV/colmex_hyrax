# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  # Generated form for Article
  class ArticleForm < Hyrax::Forms::WorkForm
    self.model_class = ::Article
    self.terms += [:period, :part, :volume, :number, :issn]
    self.terms += ArticlesAndChaptersForm.shared_fields
    # This must be included at the end,
    self.terms += ConacytForm.special_fields
  end
end
