# Generated via
#  `rails generate hyrax:work Audio`
module Hyrax
  class AudioPresenter < Hyrax::WorkShowPresenter
    delegate :is_lyricist_person_of, :is_composer_person_of, :is_performer_agent_of,
    :is_instrumentalist_agent_of, :is_singer_agent_of, :has_medium_of_performance_of_musical_content, to: :solr_document
  end
end
