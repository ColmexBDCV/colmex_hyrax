# Generated via
#  `rails generate hyrax:work Journal`
require 'rails_helper'

RSpec.describe Hyrax::JournalPresenter do
  

  it_behaves_like "analytics type two presenter" do
    let(:solr_document) { instance_double(SolrDocument) }
    let(:ability) { instance_double(Ability) }
    let(:presenter) { described_class.new(solr_document, ability) }
  end
end
