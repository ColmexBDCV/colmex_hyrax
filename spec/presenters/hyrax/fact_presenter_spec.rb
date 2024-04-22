# Generated via
#  `rails generate hyrax:work Fact`
require 'rails_helper'

RSpec.describe Hyrax::FactPresenter do
  let(:solr_document) { instance_double(SolrDocument) }
  let(:ability) { instance_double(Ability) }
  let(:presenter) { described_class.new(solr_document, ability) }

  describe 'delegation to solr_document' do
    it 'delegates related_place_of_timespan' do
      expect(solr_document).to receive(:related_place_of_timespan)
      presenter.related_place_of_timespan
    end
  end
end
