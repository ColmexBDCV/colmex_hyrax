# Generated via
#  `rails generate hyrax:work GenericWork`
require 'rails_helper'

RSpec.describe Hyrax::GenericWorkPresenter do
  let(:solr_document) { instance_double(SolrDocument) }
  let(:ability) { instance_double(Ability) }
  let(:presenter) { described_class.new(solr_document, ability) }

  it_behaves_like "series presenter" do
  end
end
