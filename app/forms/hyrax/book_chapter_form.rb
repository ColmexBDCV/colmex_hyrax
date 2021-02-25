# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  # Generated form for Book
  class BookChapterForm < Hyrax::Forms::WorkForm
    self.model_class = ::BookChapter
    self.terms += BooksAndChaptersForm.shared_fields
    self.terms += ArticlesAndChaptersForm.shared_fields
    self.terms += ConacytForm.special_fields
  end
end  