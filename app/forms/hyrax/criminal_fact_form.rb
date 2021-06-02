# Generated via
#  `rails generate hyrax:work CriminalFact`
module Hyrax
  # Generated form for CriminalFact
  class CriminalFactForm < Hyrax::Forms::WorkForm
    self.model_class = ::CriminalFact
    self.terms += [:resource_type, :related_place_of_timespan, :note_of_timespan]
  end
end
