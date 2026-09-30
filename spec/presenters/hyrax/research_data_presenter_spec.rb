# Generated via
#  `rails generate hyrax:work ResearchData`
require 'rails_helper'

RSpec.describe Hyrax::ResearchDataPresenter do
  let(:solr_document) { instance_double(SolrDocument) }
  let(:ability) { instance_double(Ability) }
  let(:presenter) { described_class.new(solr_document, ability) }

  describe 'delegation to solr_document' do
    it 'delegates the research data fields' do
      %i[summary_of_work nature_of_content guide_to_work analysis_of_work
         complemented_by_work production_method].each do |field|
        expect(solr_document).to receive(field)
        presenter.public_send(field)
      end
    end
  end
end
