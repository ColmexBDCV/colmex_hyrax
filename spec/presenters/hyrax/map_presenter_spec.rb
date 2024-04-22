# Generated via
#  `rails generate hyrax:work Map`
require 'rails_helper'

RSpec.describe Hyrax::MapPresenter do
  describe 'delegation to solr_document' do
    let(:solr_document) { instance_double(SolrDocument) }
    let(:ability) { instance_double(Ability) }
    let(:presenter) { described_class.new(solr_document, ability) }

    it 'delegates scale' do
      expect(solr_document).to receive(:scale)
      presenter.scale
    end

    it 'delegates longitud_and_latitud' do
      expect(solr_document).to receive(:longitud_and_latitud)
      presenter.longitud_and_latitud
    end

    it 'delegates digital_representation_of_cartographic_content' do
      expect(solr_document).to receive(:digital_representation_of_cartographic_content)
      presenter.digital_representation_of_cartographic_content
    end
  end
end
