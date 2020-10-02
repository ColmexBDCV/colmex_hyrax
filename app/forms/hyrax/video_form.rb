# Generated via
#  `rails generate hyrax:work Video`
module Hyrax
  # Generated form for Video
  class VideoForm < Hyrax::Forms::WorkForm
    self.model_class = ::Video
    self.terms += [:resource_type, :video_format, :video_characteristic, :note_on_statement_of_resposibility]
  end
end
