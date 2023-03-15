# Generated via
#  `rails generate hyrax:work Video`
module Hyrax
  # Generated form for Video
  class VideoForm < Hyrax::Forms::WorkForm
    self.model_class = ::Video
    self.terms += SeriesForm.shared_fields
    self.terms += [:resource_type, :video_format, :video_characteristic]
  end
end
