# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  # Generated form for Book
  class BookForm < Hyrax::Forms::WorkForm
    self.model_class = ::Book
    self.terms += [:resource_type]
    self.terms += BooksAndChaptersForm.shared_fields
    self.terms += ConacytForm.special_fields

  end
end
