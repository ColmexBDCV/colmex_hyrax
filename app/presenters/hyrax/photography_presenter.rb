# Generated via
#  `rails generate hyrax:work Photography`
module Hyrax
  class PhotographyPresenter < Hyrax::WorkShowPresenter
    delegate :photographer_corporate_body_of_work, :dimensions_of_still_image, to: :solr_document
  end
end
