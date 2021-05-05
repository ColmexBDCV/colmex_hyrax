# Generated via
#  `rails generate hyrax:work Music`
module Hyrax
  class MusicPresenter < Hyrax::WorkShowPresenter
    delegate :is_lyricist_person_of, :is_composer_person_of, to: :solr_document
  end
end
