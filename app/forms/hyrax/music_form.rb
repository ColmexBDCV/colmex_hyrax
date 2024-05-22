# Generated via
#  `rails generate hyrax:work Music`
module Hyrax
  # Generated form for Music
  class MusicForm < Hyrax::Forms::WorkForm
    self.model_class = ::Music
    self.terms += [:resource_type, :is_lyricist_person_of, :is_composer_person_of, :is_performer_agent_of,
    :is_instrumentalist_agent_of,
    :is_singer_agent_of ]
  end
end
