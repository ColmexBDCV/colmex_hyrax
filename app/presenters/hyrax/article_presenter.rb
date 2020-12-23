# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  class ArticlePresenter < Hyrax::WorkShowPresenter

    delegate :volume, :number, :period, :part, :issn, to: :solr_document
    include Hyrax::ArticlesAndChaptersPresenter
    include Hyrax::ConacytPresenter

  end
end
