# Generated via
#  `rails generate hyrax:work ArchivalDocument`
require 'rails_helper'

RSpec.describe Hyrax::ArchivalDocumentPresenter do
  let(:solr_document) { instance_double(SolrDocument) }
  let(:ability) { instance_double(Ability) }
  let(:presenter) { described_class.new(solr_document, ability) }

  describe 'delegation to solr_document' do
    it 'delegates is_finding_aid_for' do
      expect(solr_document).to receive(:is_finding_aid_for)
      presenter.is_finding_aid_for
    end
  end
end
