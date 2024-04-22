require 'rails_helper'

RSpec.describe Hyrax::BookChapterForm do
  describe 'terms' do
    subject { described_class.terms }

    let(:expected_terms) {
      Hyrax::AnalyticsTypeOneForm.shared_fields +  Hyrax::SeriesForm.shared_fields +  Hyrax::ConacytForm.special_fields + [:resource_type]
    }

    it 'includes all shared fields and resource_type' do
      expect(subject).to include(*expected_terms)
    end
  end
end

