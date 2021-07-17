# Generated via
#  `rails generate hyrax:work ArchivalDocument`
module Hyrax
  # Generated form for ArchivalDocument
  class ArchivalDocumentForm < Hyrax::Forms::WorkForm
    self.model_class = ::ArchivalDocument
    self.terms += [:resource_type, :is_finding_aid_for]
  end
end
