# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  class BookPresenter < Hyrax::WorkShowPresenter
    include Hyrax::SeriesPresenter
    include Hyrax::ConacytPresenter
  end
end
