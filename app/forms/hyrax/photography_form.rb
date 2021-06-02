# Generated via
#  `rails generate hyrax:work Photography`
module Hyrax
  # Generated form for Photography
  class PhotographyForm < Hyrax::Forms::WorkForm
    self.model_class = ::Photography
    self.terms += [:resource_type, :photographer_corporate_body_of_work, :dimensions_of_still_image]
  end
end
