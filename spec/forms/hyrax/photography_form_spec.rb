require 'rails_helper'

RSpec.describe Hyrax::PhotographyForm do
  describe 'terms' do
    subject { described_class.terms }

    let(:expected_terms) {
      [:resource_type, :photographer_corporate_body_of_work, :dimensions_of_still_image]
    }

    it 'includes all shared fields and resource_type' do
      expect(subject).to include(*expected_terms)
    end
  end
end