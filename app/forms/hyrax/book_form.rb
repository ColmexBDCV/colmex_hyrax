# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  # Generated form for Book
  class BookForm < Hyrax::Forms::WorkForm
    self.model_class = ::Book
    self.terms += [:corporate_body, :collective_agent, :organizer_author, :place_of_publication, :copyright, :title_of_series, :numbering_within_sequence]
    self.terms += ConacytForm.special_fields

  end
end
