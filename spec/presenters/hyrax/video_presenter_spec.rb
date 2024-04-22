# Generated via
#  `rails generate hyrax:work Video`
require 'rails_helper'

RSpec.describe Hyrax::VideoPresenter do
  let(:solr_document) { instance_double(SolrDocument) }
  let(:ability) { instance_double(Ability) }
  let(:presenter) { described_class.new(solr_document, ability) }

  it 'delegates video_format' do
    expect(solr_document).to receive(:video_format)
    presenter.video_format
  end

  it 'delegates video_characteristic' do
    expect(solr_document).to receive(:video_characteristic)
    presenter.video_characteristic
  end
    
  it_behaves_like "series presenter" do
  end

  it_behaves_like "conacyt presenter" do
  end
end
