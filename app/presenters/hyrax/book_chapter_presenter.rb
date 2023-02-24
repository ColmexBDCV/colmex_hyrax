# Generated via
#  `rails generate hyrax:work BookChapter`
module Hyrax
  class BookChapterPresenter < Hyrax::WorkShowPresenter
    include Hyrax::AnalyticsTypeOnePresenter
    include Hyrax::SeriesPresenter
    include Hyrax::ConacytPresenter
  end
end
