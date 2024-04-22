require 'rails_helper'

RSpec.describe Hyrax::ArchivalDocumentForm do
  describe 'terms' do
    subject { described_class.terms }

    let(:expected_terms) {
      [:resource_type, :is_finding_aid_for]
    }

    it 'includes all shared fields and resource_type' do
      expect(subject).to include(*expected_terms)
    end
  end
end
