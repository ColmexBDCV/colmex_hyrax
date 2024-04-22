# Generated via
#  `rails generate hyrax:work Amparo`
require 'rails_helper'

RSpec.describe Hyrax::AmparoPresenter do
  it_behaves_like "legal document presenter" do
    let(:solr_document) { instance_double(SolrDocument) }
    let(:ability) { instance_double(Ability) }
    let(:presenter) { described_class.new(solr_document, ability) }
  end
end
