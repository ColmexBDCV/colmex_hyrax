# Generated via
#  `rails generate hyrax:work Amparo`
require 'rails_helper'

RSpec.shared_examples "series presenter" do
    it 'delegates copyright' do
        expect(solr_document).to receive(:copyright)
        presenter.copyright
    end

    it 'delegates title_of_series' do
        expect(solr_document).to receive(:title_of_series)
        presenter.title_of_series
    end

    it 'delegates numbering_within_sequence' do
        expect(solr_document).to receive(:numbering_within_sequence)
        presenter.numbering_within_sequence
    end
end
