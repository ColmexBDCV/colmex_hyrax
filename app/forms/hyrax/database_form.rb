# Generated via
#  `rails generate hyrax:work DataBase`
module Hyrax
  # Generated form for DataBase
  class DatabaseForm < Hyrax::Forms::WorkForm
    self.model_class = ::Database
    self.terms += [:resource_type, :summary_of_work, :nature_of_content, :guide_to_work, :analysis_of_work, :complemented_by_work, :production_method]
  end
end
