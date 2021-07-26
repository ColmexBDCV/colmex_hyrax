# Generated via
#  `rails generate hyrax:work Legaslation`
module Hyrax
  class LegaslationPresenter < Hyrax::WorkShowPresenter
    include Hyrax::AnalyticsTypeOnePresenter
    include Hyrax::AnalyticsTypeTwoPresenter
  end
end
