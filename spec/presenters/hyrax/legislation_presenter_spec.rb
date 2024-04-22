# Generated via
#  `rails generate hyrax:work Legislation`
require 'rails_helper'

RSpec.describe Hyrax::LegislationPresenter do
  let(:solr_document) { instance_double(SolrDocument) }
  let(:ability) { instance_double(Ability) }
  let(:presenter) { described_class.new(solr_document, ability) }

  it_behaves_like "analytics type one presenter" do
  end

  it_behaves_like "analytics type two presenter" do
  end
end
