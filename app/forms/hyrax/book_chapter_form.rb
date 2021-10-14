# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  # Generated form for Book
  class BookChapterForm < Hyrax::Forms::WorkForm
    self.model_class = ::BookChapter
    self.terms += [:resource_type]
    self.terms += AnalyticsTypeOneForm.shared_fields
    self.terms += BooksAndChaptersForm.shared_fields
    self.terms += ConacytForm.special_fields
  end
end  