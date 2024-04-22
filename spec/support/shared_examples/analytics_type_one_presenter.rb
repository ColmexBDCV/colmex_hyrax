# Generated via
#  `rails generate hyrax:work Amparo`
require 'rails_helper'

RSpec.shared_examples "analytics type one presenter" do
    it 'delegates alternative_numeric_and_or_alphabethic_designation' do
        expect(solr_document).to receive(:alternative_numeric_and_or_alphabethic_designation)
        presenter.alternative_numeric_and_or_alphabethic_designation
    end

    it 'delegates is_part_or_work' do
        expect(solr_document).to receive(:is_part_or_work)
        presenter.is_part_or_work
    end
    
end
