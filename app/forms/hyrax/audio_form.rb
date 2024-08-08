# Generated via
#  `rails generate hyrax:work Audio`
module Hyrax
  # Generated form for Audio
  class AudioForm < Hyrax::Forms::WorkForm
    self.model_class = ::Audio
    self.terms += [:resource_type, :is_lyricist_person_of, :is_composer_person_of, :is_performer_agent_of,
    :is_instrumentalist_agent_of,
    :is_singer_agent_of ]
  end
end
