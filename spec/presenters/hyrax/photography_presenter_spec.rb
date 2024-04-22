# Generated via
#  `rails generate hyrax:work Photography`
require 'rails_helper'

RSpec.describe Hyrax::PhotographyPresenter do
  describe 'delegation to solr_document' do
    let(:solr_document) { instance_double(SolrDocument) }
    let(:ability) { instance_double(Ability) }
    let(:presenter) { described_class.new(solr_document, ability) }
    it 'delegates photographer_corporate_body_of_work' do
      expect(solr_document).to receive(:photographer_corporate_body_of_work)
      presenter.photographer_corporate_body_of_work
    end

    it 'delegates dimensions_of_still_image' do
      expect(solr_document).to receive(:dimensions_of_still_image)
      presenter.dimensions_of_still_image
    end
  end
end
