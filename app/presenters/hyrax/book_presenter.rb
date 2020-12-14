# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  class BookPresenter < Hyrax::WorkShowPresenter
    include Hyrax::BooksAndChaptersPresenter
    include Hyrax::ConacytPresenter
  end
end
