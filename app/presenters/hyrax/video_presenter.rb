# Generated via
#  `rails generate hyrax:work Video`
module Hyrax
  class VideoPresenter < Hyrax::WorkShowPresenter
    delegate :video_format, :video_characteristic,
    to: :solr_document
    
    include Hyrax::SeriesPresenter
    # This must be included at the end,
    include Hyrax::ConacytPresenter
  end
end
