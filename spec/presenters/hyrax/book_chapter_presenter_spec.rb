# Generated via
#  `rails generate hyrax:work BookChapter`
require 'rails_helper'

RSpec.describe Hyrax::BookChapterPresenter do
  let(:solr_document) { instance_double(SolrDocument) }
  let(:ability) { instance_double(Ability) }
  let(:presenter) { described_class.new(solr_document, ability) }
 
  it_behaves_like "analytics type one presenter" do
  end

  it_behaves_like "series presenter" do
  end

  it_behaves_like "conacyt presenter" do
  end
  
end
