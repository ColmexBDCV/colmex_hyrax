require 'rails_helper'

RSpec.describe Hyrax::JurisprudentialThesisForm do
  describe 'terms' do
    subject { described_class.terms }

    let(:expected_terms) {
      Hyrax::LegalDocumentsForm.shared_fields + [:resource_type, :period_of_activity_of_corporate_body, :speaker_agent_of, :assistant, :preceded_by_work]
    }

    it 'includes all shared fields and resource_type' do
      expect(subject).to include(*expected_terms)
    end
  end
end