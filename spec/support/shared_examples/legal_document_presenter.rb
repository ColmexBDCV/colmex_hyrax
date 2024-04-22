# Generated via
#  `rails generate hyrax:work Amparo`
require 'rails_helper'

RSpec.shared_examples "legal document presenter" do
    it 'delegates primary_topic' do
        expect(solr_document).to receive(:primary_topic)
        presenter.primary_topic
    end

    it 'delegates enacting_juridiction_of' do
        expect(solr_document).to receive(:enacting_juridiction_of)
        presenter.enacting_juridiction_of
    end

    it 'delegates hierarchical_superior' do
        expect(solr_document).to receive(:hierarchical_superior)
        presenter.hierarchical_superior
    end

    # Continúa para el resto de métodos delegados...
    it 'delegates hierarchical_inferior' do
        expect(solr_document).to receive(:hierarchical_inferior)
        presenter.hierarchical_inferior
    end

    it 'delegates subject_timespan' do
        expect(solr_document).to receive(:subject_timespan)
        presenter.subject_timespan
    end

    it 'delegates identifier_of_work' do
        expect(solr_document).to receive(:identifier_of_work)
        presenter.identifier_of_work
    end

    it 'delegates is_title_of_item_of' do
        expect(solr_document).to receive(:is_title_of_item_of)
        presenter.is_title_of_item_of
    end

    it 'delegates timespan_described_in' do
        expect(solr_document).to receive(:timespan_described_in)
        presenter.timespan_described_in
    end

    it 'delegates related_person_of' do
        expect(solr_document).to receive(:related_person_of)
        presenter.related_person_of
    end

    it 'delegates related_corporate_body_of_timespan' do
        expect(solr_document).to receive(:related_corporate_body_of_timespan)
        presenter.related_corporate_body_of_timespan
    end

    it 'delegates related_family_timespan' do
        expect(solr_document).to receive(:related_family_timespan)
        presenter.related_family_timespan
    end

    it 'delegates complainant' do
        expect(solr_document).to receive(:complainant)
        presenter.complainant
    end

    it 'delegates contestee' do
        expect(solr_document).to receive(:contestee)
        presenter.contestee
    end

    it 'delegates witness' do
        expect(solr_document).to receive(:witness)
        presenter.witness
    end

    it 'delegates is_criminal_defendant_corporate_body_of' do
        expect(solr_document).to receive(:is_criminal_defendant_corporate_body_of)
        presenter.is_criminal_defendant_corporate_body_of
    end

    it 'delegates is_criminal_defendant_person_of' do
        expect(solr_document).to receive(:is_criminal_defendant_person_of)
        presenter.is_criminal_defendant_person_of
    end

    it 'delegates has_identifier_for_item' do
        expect(solr_document).to receive(:has_identifier_for_item)
        presenter.has_identifier_for_item
    end
  
end
