# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  class WorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::Work
    self.terms += [:resource_type, :subject_conacyt, :creator_conacyt, :contributor_conacyt]
  end
end
