# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  class WorkPresenter < Hyrax::WorkShowPresenter
    delegate :subject_conacyt, :creator_conacyt, :contributor_conacyt, to: :solr_document
  end
end
