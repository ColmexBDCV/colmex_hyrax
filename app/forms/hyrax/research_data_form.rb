# Generated via
#  `rails generate hyrax:work ResearchData`
module Hyrax
  # Generated form for ResearchData
  class ResearchDataForm < Hyrax::Forms::WorkForm
    self.model_class = ::ResearchData
    self.terms += [:resource_type, :summary_of_work, :nature_of_content, :guide_to_work,
                   :analysis_of_work, :complemented_by_work, :production_method]
  end
end
