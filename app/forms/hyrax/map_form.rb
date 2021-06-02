# Generated via
#  `rails generate hyrax:work Map`
module Hyrax
  # Generated form for Map
  class MapForm < Hyrax::Forms::WorkForm
    self.model_class = ::Map
    self.terms += [:resource_type, :scale, :longitud_and_latitud, :digital_representation_of_cartographic_content]
  end
end
