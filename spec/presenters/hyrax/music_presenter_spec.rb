# Generated via
#  `rails generate hyrax:work Music`
require 'rails_helper'

RSpec.describe Hyrax::MusicPresenter do
  describe 'delegation to solr_document' do
    let(:solr_document) { instance_double(SolrDocument) }
    let(:ability) { instance_double(Ability) }
    let(:presenter) { described_class.new(solr_document, ability) }
    it 'delegates is_lyricist_person_of' do
      expect(solr_document).to receive(:is_lyricist_person_of)
      presenter.is_lyricist_person_of
    end

    it 'delegates is_composer_person_of' do
      expect(solr_document).to receive(:is_composer_person_of)
      presenter.is_composer_person_of
    end

    it 'delegates is_performer_agent_of' do
      expect(solr_document).to receive(:is_performer_agent_of)
      presenter.is_performer_agent_of
    end

    it 'delegates is_instrumentalist_agent_of' do
      expect(solr_document).to receive(:is_instrumentalist_agent_of)
      presenter.is_instrumentalist_agent_of
    end

    it 'delegates is_singer_agent_of' do
      expect(solr_document).to receive(:is_singer_agent_of)
      presenter.is_singer_agent_of
    end
  end

end
