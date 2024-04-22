require 'rails_helper'

RSpec.describe Hyrax::ThesisForm do
  describe 'terms' do
    subject { described_class.terms }

    let(:expected_terms) {
      Hyrax::ConacytForm.special_fields + [:resource_type, :director, :awards, 
      :academic_degree, :type_of_thesis, :degree_program, :institution,  
      :date_of_presentation_of_the_thesis]
    }

    it 'includes all shared fields and resource_type' do
      expect(subject).to include(*expected_terms)
    end
  end
end