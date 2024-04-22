# Generated via
#  `rails generate hyrax:work JurisprudentialThesis`
require 'rails_helper'

RSpec.describe Hyrax::JurisprudentialThesisPresenter do
  let(:solr_document) { instance_double(SolrDocument) }
  let(:ability) { instance_double(Ability) }
  let(:presenter) { described_class.new(solr_document, ability) }

  describe 'delegation to solr_document' do
    it 'delegates period_of_activity_of_corporate_body' do
      expect(solr_document).to receive(:period_of_activity_of_corporate_body)
      presenter.period_of_activity_of_corporate_body
    end

    it 'delegates speaker_agent_of' do
      expect(solr_document).to receive(:speaker_agent_of)
      presenter.speaker_agent_of
    end

    it 'delegates assistant' do
      expect(solr_document).to receive(:assistant)
      presenter.assistant
    end

    it 'delegates preceded_by_work' do
      expect(solr_document).to receive(:preceded_by_work)
      presenter.preceded_by_work
    end
  end
end
