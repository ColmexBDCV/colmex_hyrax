# Generated via
#  `rails generate hyrax:work Map`
module Hyrax
  class MapPresenter < Hyrax::WorkShowPresenter
    delegate :scale, :longitud_and_latitud, :digital_representation_of_cartographic_content, to: :solr_document
  end
end
