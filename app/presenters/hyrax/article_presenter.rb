# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  class ArticlePresenter < Hyrax::WorkShowPresenter

    include Hyrax::AnalyticsTypeOnePresenter
    include Hyrax::AnalyticsTypeTwoPresenter
    include Hyrax::ConacytPresenter
   
  end
end
