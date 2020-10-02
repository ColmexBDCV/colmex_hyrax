# Generated via
#  `rails generate hyrax:work Video`
module Hyrax
  class VideoPresenter < Hyrax::WorkShowPresenter
    delegate :video_format, :video_characteristic, :note_on_statement_of_resposibility,
    to: :solr_document

    # This must be included at the end,
    include Hyrax::ConacytPresenter
  end
end
