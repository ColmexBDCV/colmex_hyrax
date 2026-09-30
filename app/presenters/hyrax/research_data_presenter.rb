# Generated via
#  `rails generate hyrax:work ResearchData`
module Hyrax
  class ResearchDataPresenter < Hyrax::WorkShowPresenter
    delegate :system_created, :system_modified, :summary_of_work, :nature_of_content,
             :guide_to_work, :analysis_of_work, :complemented_by_work, :production_method,
             to: :solr_document
  end
end
