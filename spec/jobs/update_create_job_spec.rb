require 'rails_helper'

RSpec.describe UpdateCreateJob, type: :job do
  let(:update_record) { Update.create!(name: 'sip', status: 'Procesando...') }
  let(:parser_double) { instance_double(ColmexCsvParser) }
  let(:importer_double) { instance_double(Importer) }

  before do
    allow(ColmexCsvParser).to receive(:new).and_return(parser_double)
    allow(Importer).to receive(:new).and_return(importer_double)
    allow(importer_double).to receive(:import)
    allow(File).to receive(:open).and_return(double('file'))
  end

  it 'instancia el parser con el archivo correcto' do
    expect(ColmexCsvParser).to receive(:new).with(
      hash_including(work: 'Book')
    )
    UpdateCreateJob.perform_now('digital_objects/sip/metadatos/metadatos.csv', 'Book', update_record.id)
  end

  it 'instancia Importer con update: true y update_id' do
    expect(Importer).to receive(:new).with(
      hash_including(update: true, update_id: update_record.id)
    ).and_return(importer_double)
    UpdateCreateJob.perform_now('digital_objects/sip/metadatos/metadatos.csv', 'Book', update_record.id)
  end

  it 'llama import en el importer' do
    expect(importer_double).to receive(:import)
    UpdateCreateJob.perform_now('digital_objects/sip/metadatos/metadatos.csv', 'Book', update_record.id)
  end

  it 'funciona sin update_id (nil)' do
    expect { UpdateCreateJob.perform_now('path.csv', 'Book') }.not_to raise_error
  end
end
