# Generated via
#  `rails generate hyrax:work DataBase`
require 'rails_helper'

RSpec.describe Hyrax::DatabasePresenter do
  let(:solr_document) { instance_double(SolrDocument) }
  let(:ability) { instance_double(Ability) }
  let(:presenter) { described_class.new(solr_document, ability) }
  describe 'delegation to solr_document' do
    it 'delegates summary_of_work' do
      expect(solr_document).to receive(:summary_of_work)
      presenter.summary_of_work
    end

    it 'delegates nature_of_content' do
      expect(solr_document).to receive(:nature_of_content)
      presenter.nature_of_content
    end

    it 'delegates guide_to_work' do
      expect(solr_document).to receive(:guide_to_work)
      presenter.guide_to_work
    end

    it 'delegates analysis_of_work' do
      expect(solr_document).to receive(:analysis_of_work)
      presenter.analysis_of_work
    end

    it 'delegates complemented_by_work' do
      expect(solr_document).to receive(:complemented_by_work)
      presenter.complemented_by_work
    end

    it 'delegates production_method' do
      expect(solr_document).to receive(:production_method)
      presenter.production_method
    end
  end
end
