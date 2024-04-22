require 'rails_helper'

RSpec.describe Hyrax::FactForm do
  describe 'terms' do
    subject { described_class.terms }

    let(:expected_terms) {
      Hyrax::LegalDocumentsForm.shared_fields + [:resource_type, :related_place_of_timespan]
    }

    it 'includes all shared fields and resource_type' do
      expect(subject).to include(*expected_terms)
    end
  end
end
