# Generated via
#  `rails generate hyrax:work Amparo`
require 'rails_helper'

RSpec.shared_examples "analytics type two presenter" do
    it 'delegates issn' do
        expect(solr_document).to receive(:issn)
        presenter.issn
    end

    it 'delegates volume' do
        expect(solr_document).to receive(:volume)
        presenter.volume
    end

    it 'delegates number' do
        expect(solr_document).to receive(:number)
        presenter.number
    end

    
  
end
