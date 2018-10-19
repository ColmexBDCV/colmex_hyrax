# Generated via
#  `rails generate hyrax:work Thesis`
module Hyrax
  # Generated form for Thesis
  class ThesisForm < Hyrax::Forms::WorkForm
    include Hyrax::ConacytForm

    self.model_class = ::Thesis
    self.terms += [:resource_type, :director, :other_related_persons, :awards, :type_of_content, 
      :type_of_illustrations, :summary, :supplementary_content_or_bibliography, 
      :item_access_restrictions, :item_use_restrictions, :edition, :encoding_format_details, 
      :file_type_details, :digital_resource_generation_information, :file_details, :dimensions, 
      :system_requirements, :exemplar_of_manifestation, :extension, :type_of_file, :mode_of_publication, 
      :other_formats, :access_restrictions, :use_restrictions, :responsibility_statement, 
      :academic_degree, :type_of_thesis, :degree_program, :institution, :center, :classification, 
      :table_of_contents, :date_of_presentation_of_the_thesis]
      
       # This must be included at the end,
      self.terms += ConacytForm.special_fields
  end
end
