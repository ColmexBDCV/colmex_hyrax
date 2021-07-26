# Generated via
#  `rails generate hyrax:work Legislation`
module Hyrax
  class LegislationPresenter < Hyrax::WorkShowPresenter
    include Hyrax::AnalyticsTypeOnePresenter
    include Hyrax::AnalyticsTypeTwoPresenter
  end
end
