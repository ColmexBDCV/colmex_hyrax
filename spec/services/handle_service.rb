require 'rails_helper'

RSpec.describe HandleService do
  describe '.assing_handle_for_worktype' do
    it 'consulta obras con handle nil o vacio' do
      stub_const('MyWork', Class.new)
      expect(MyWork).to receive(:where).with(handle: [nil, '']).and_return([])

      HandleService.assing_handle_for_worktype('my_works')
    end
  end

  describe '.assing_handle_for_all' do
    it 'consulta obras con handle nil o vacio para cada worktype registrado' do
      stub_const('MyWork', Class.new)
      allow(Hyrax::config).to receive(:registered_curation_concern_types).and_return(['my_works'])
      expect(MyWork).to receive(:where).with(handle: [nil, '']).and_return([])

      HandleService.assing_handle_for_all
    end
  end
end