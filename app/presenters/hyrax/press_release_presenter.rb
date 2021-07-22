# Generated via
#  `rails generate hyrax:work PressRelease`
module Hyrax
  class PressReleasePresenter < Hyrax::WorkShowPresenter
    include Hyrax::AnalyticsTypeOnePresenter
    include Hyrax::AnalyticsTypeTwoPresenter
  end
end
