# Generated via
#  `rails generate hyrax:work Amparo`
require 'rails_helper'

RSpec.shared_examples "conacyt presenter" do
    it 'delegates subject_conacyt' do
        expect(solr_document).to receive(:subject_conacyt)
        presenter.subject_conacyt
    end

    it 'delegates creator_conacyt' do
        expect(solr_document).to receive(:creator_conacyt)
        presenter.creator_conacyt
    end

    it 'delegates contributor_conacyt' do
        expect(solr_document).to receive(:contributor_conacyt)
        presenter.contributor_conacyt
    end

    it 'delegates pub_conacyt' do
        expect(solr_document).to receive(:pub_conacyt)
        presenter.pub_conacyt
    end

    it 'delegates type_conacyt' do
        expect(solr_document).to receive(:type_conacyt)
        presenter.type_conacyt
    end
  
end
