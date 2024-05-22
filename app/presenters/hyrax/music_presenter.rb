# Generated via
#  `rails generate hyrax:work Music`
module Hyrax
  class MusicPresenter < Hyrax::WorkShowPresenter
    delegate :is_lyricist_person_of, :is_composer_person_of, :is_performer_agent_of,
    :is_instrumentalist_agent_of, :is_singer_agent_of, to: :solr_document
  end
end
