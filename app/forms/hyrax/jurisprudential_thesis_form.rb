# Generated via
#  `rails generate hyrax:work JurisprudentialThesis`
module Hyrax
  # Generated form for JurisprudentialThesis
  class JurisprudentialThesisForm < Hyrax::Forms::WorkForm
    self.model_class = ::JurisprudentialThesis
    self.terms += [:resource_type, :period_of_activity_of_corporate_body, :speaker_agent_of, :assistant, :preceded_by_work]
    self.terms += LegalDocumentsForm.shared_fields
  end
end
