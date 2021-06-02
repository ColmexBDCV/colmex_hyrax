# Generated via
#  `rails generate hyrax:work JurisprudentialThesis`
module Hyrax
  class JurisprudentialThesisPresenter < Hyrax::WorkShowPresenter
    include Hyrax::LegalDocumentsPresenter

    delegate :period_of_activity_of_corporate_body, :speaker_agent_of, :assistant, :preceded_by_work, to: :solr_document
  end
end
