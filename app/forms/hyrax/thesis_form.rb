# Generated via
#  `rails generate hyrax:work Thesis`
module Hyrax
  # Generated form for Thesis
  class ThesisForm < Hyrax::Forms::WorkForm
    include Hyrax::ConacytForm

    self.model_class = ::Thesis
    self.terms += [:director, :awards, 
      :academic_degree, :type_of_thesis, :degree_program, :institution,  
      :date_of_presentation_of_the_thesis]
      
       # This must be included at the end,
      self.terms += ConacytForm.special_fields
  end
end
