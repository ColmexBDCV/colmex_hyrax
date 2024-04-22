require 'rails_helper'

RSpec.describe Hyrax::DatabaseForm do
  describe 'terms' do
    subject { described_class.terms }

    let(:expected_terms) {
      [:resource_type, :summary_of_work, :nature_of_content, :guide_to_work, :analysis_of_work, :complemented_by_work, :production_method]
    }

    it 'includes all shared fields and resource_type' do
      expect(subject).to include(*expected_terms)
    end
  end
end
