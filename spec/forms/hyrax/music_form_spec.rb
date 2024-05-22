require 'rails_helper'

RSpec.describe Hyrax::MusicForm do
  describe 'terms' do
    subject { described_class.terms }

    let(:expected_terms) {
      [:resource_type, :is_lyricist_person_of, :is_composer_person_of, :is_performer_agent_of,
      :is_instrumentalist_agent_of, :is_singer_agent_of ]
    }

    it 'includes all shared fields and resource_type' do
      expect(subject).to include(*expected_terms)
    end
  end
end