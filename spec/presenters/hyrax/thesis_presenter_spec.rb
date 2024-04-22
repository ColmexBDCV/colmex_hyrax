# Generated via
#  `rails generate hyrax:work Thesis`
require 'rails_helper'

RSpec.describe Hyrax::ThesisPresenter do
  let(:solr_document) { instance_double(SolrDocument) }
  let(:ability) { instance_double(Ability) }
  let(:presenter) { described_class.new(solr_document, ability) }

  it 'delegates director' do
    expect(solr_document).to receive(:director)
    presenter.director
  end

  it 'delegates awards' do
    expect(solr_document).to receive(:awards)
    presenter.awards
  end
  
  it 'delegates academic_degree' do
    expect(solr_document).to receive(:academic_degree)
    presenter.academic_degree
  end

  it 'delegates type_of_thesis' do
    expect(solr_document).to receive(:type_of_thesis)
    presenter.type_of_thesis
  end

  it 'delegates degree_program' do
    expect(solr_document).to receive(:degree_program)
    presenter.degree_program
  end

  it 'delegates institution' do
    expect(solr_document).to receive(:institution)
    presenter.institution
  end

  it 'delegates date_of_presentation_of_the_thesis' do
    expect(solr_document).to receive(:date_of_presentation_of_the_thesis)
    presenter.date_of_presentation_of_the_thesis
  end

  it_behaves_like "conacyt presenter" do
  end
end
