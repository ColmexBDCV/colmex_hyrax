# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  class ArticlePresenter < Hyrax::WorkShowPresenter

    delegate :period, :part, :year, :volume, :number, :mode_of_issuance, :pages, :contained_in, to: :solr_document

    include Hyrax::ConacytPresenter

  end
end
