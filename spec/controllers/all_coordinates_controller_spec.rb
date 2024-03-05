require 'rails_helper'

RSpec.describe AllCoordinatesController, type: :controller do
  let(:solr_double) { instance_double(RSolr::Client) }
  let(:solr_response) do
    double('solr response', response: { body: '{"response":{"docs":[],"numFound":1}}' })
  end

  before do
    allow(controller).to receive(:solr).and_return(solr_double)
    allow(solr_double).to receive(:paginate).and_return(solr_response)
  end

  describe 'GET #fetch_docs' do
    it 'returns a successful response' do
      get :fetch_docs, params: { query: 'test' }
      expect(response).to be_successful
    end

    it 'returns the correct number of documents' do
      get :fetch_docs, params: { query: 'test' }
      docs = JSON.parse(response.body)
      expect(docs).to be_a(Array)
      expect(docs.size).to eq(0) # Ajusta esto según los datos de prueba esperados
    end
  end
end
