# Generated via
#  `rails generate hyrax:work BookChapter`
module Hyrax
  class BookChapterPresenter < Hyrax::WorkShowPresenter
    include Hyrax::AnalyticsTypeOnePresenter
    include Hyrax::BooksAndChaptersPresenter
    include Hyrax::ConacytPresenter
  end
end
