# Generated via
#  `rails generate hyrax:work DataBase`
module Hyrax
  class DatabasePresenter < Hyrax::WorkShowPresenter
    delegate :researcher_agent_of, :summary_of_work, :nature_of_content, 
    :guide_to_work, :analysis_of_work, :complemented_by_work, :production_method, to: :solr_document
  end
end
