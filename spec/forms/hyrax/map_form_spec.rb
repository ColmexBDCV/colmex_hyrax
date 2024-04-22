require 'rails_helper'

RSpec.describe Hyrax::MapForm do
  describe 'terms' do
    subject { described_class.terms }

    let(:expected_terms) {
      [:resource_type, :scale, :longitud_and_latitud, :digital_representation_of_cartographic_content]
    }

    it 'includes all shared fields and resource_type' do
      expect(subject).to include(*expected_terms)
    end
  end
end