require 'rails_helper'
require 'csv'

RSpec.describe ImporterService, type: :module do
  include ImporterService

  let(:sip) { 'sip_prueba_update' }
  let(:work) { 'Book' }
  let(:wt_double) { class_double('Book') }

  before do
    allow(wt_double).to receive(:where).and_return(double(count: 1))
  end

  describe '#validate_non_existing_identifier' do
    let(:record) { double('record', identifier: 'id1', respond_to?: true) }

    it 'retorna nil cuando el identifier SÍ existe (update valido)' do
      allow(wt_double).to receive(:where).with(identifier: 'id1').and_return(double(count: 1))
      expect(validate_non_existing_identifier(record, 0, wt_double)).to be_nil
    end

    it 'retorna error cuando el identifier NO existe' do
      allow(wt_double).to receive(:where).with(identifier: 'id1').and_return(double(count: 0))
      result = validate_non_existing_identifier(record, 0, wt_double)
      expect(result).not_to be_nil
      expect(result[1]).to include('id1')
    end

    it 'retorna nil si el record no responde a identifier' do
      rec = double('record')
      allow(rec).to receive(:respond_to?).with('identifier').and_return(false)
      expect(validate_non_existing_identifier(rec, 0, wt_double)).to be_nil
    end
  end

  describe '#validate_csv_update rechaza SIP sin carpeta de metadatos' do
    it 'retorna Error si no existe metadatos.csv' do
      allow(self).to receive(:metadata_exists?).and_return(false)
      result = validate_csv_update('sip_inexistente_update', work)
      expect(result[:Error]).to match(/metadatos/)
    end
  end

  describe '#validate_csv_update rechaza SIP sin carpeta documentos_de_acceso' do
    it 'retorna Error si no existe la carpeta' do
      allow(self).to receive(:metadata_exists?).and_return(true)
      allow(self).to receive(:documents_exists?).and_return(false)
      result = validate_csv_update(sip, work)
      expect(result[:Error]).to match(/documentos_de_acceso/)
    end
  end

  describe '#validate_csv_update instancia el parser en modo update' do
    let(:parser_double) { instance_double(ColmexCsvParser, validate: true) }
    let(:csv_table) { instance_double(CSV::Table, headers: [:identifier, :file_name]) }
    let(:record) { instance_double(Darlingtonia::InputRecord) }

    before do
      allow(self).to receive(:metadata_exists?).and_return(true)
      allow(self).to receive(:documents_exists?).and_return(true)
      allow(File).to receive(:open).and_return(double('file'))
      allow(ColmexCsvParser).to receive(:new).and_return(parser_double)
      allow(Importer).to receive_message_chain(:new, :records, :to_a).and_return([record])
      allow(CSV).to receive(:table).and_return(csv_table)
      allow(self).to receive(:build_validation_context).and_return({ wt: wt_double })
      allow(self).to receive(:process_records_and_report).and_return({})
    end

    it 'pasa update: true al parser' do
      expect(ColmexCsvParser).to receive(:new).with(
        hash_including(work: work, update: true)
      ).and_return(parser_double)

      validate_csv_update(sip, work)
    end
  end

  describe '#documents_exists? con require_files' do
    let(:dir) { "digital_objects/#{sip}/documentos_de_acceso" }

    it 'acepta carpeta existente vacia cuando require_files: false' do
      allow(File).to receive(:directory?).with(dir).and_return(true)
      expect(documents_exists?(sip, require_files: false)).to be true
    end

    it 'rechaza carpeta inexistente incluso con require_files: false' do
      allow(File).to receive(:directory?).with(dir).and_return(false)
      expect(documents_exists?(sip, require_files: false)).to be false
    end

    it 'rechaza carpeta vacia cuando require_files: true (modo imports)' do
      allow(File).to receive(:directory?).with(dir).and_return(true)
      allow(Dir).to receive(:entries).with(dir).and_return(['.', '..'])
      expect(documents_exists?(sip, require_files: true)).to be false
    end

    it 'acepta carpeta con archivos cuando require_files: true' do
      allow(File).to receive(:directory?).with(dir).and_return(true)
      allow(Dir).to receive(:entries).with(dir).and_return(['.', '..', 'archivo.pdf'])
      expect(documents_exists?(sip, require_files: true)).to be true
    end
  end

  describe '#validate_record modo :update' do
    let(:record) do
      double('record',
        respond_to?: true,
        identifier: 'id1', title: ['Titulo'],
        rights_statement: [], date_created: ['2021'],
        isbn: [], based_near: [], license: [],
        resource_type: []
      )
    end

    it 'no valida titulo como obligatorio en modo update' do
      rec_sin_titulo = double('record',
        respond_to?: true,
        identifier: 'id1',
        rights_statement: [], date_created: ['2021'],
        isbn: [], based_near: [], license: [],
        resource_type: []
      )
      allow(rec_sin_titulo).to receive(:respond_to?).with('title').and_return(false)
      allow(wt_double).to receive(:where).and_return(double(count: 1))

      errors = validate_record(rec_sin_titulo, 0, wt_double, [], [], [], [], [], false, :update)
      expect(errors.keys).not_to include(match(/campo title/))
    end

    it 'valida titulo como obligatorio en modo create' do
      rec_sin_titulo = double('record', respond_to?: false, identifier: 'id1',
        rights_statement: [], date_created: ['2021'],
        isbn: [], based_near: [], license: [], resource_type: [])
      allow(rec_sin_titulo).to receive(:respond_to?).with('identifier').and_return(true)
      allow(rec_sin_titulo).to receive(:respond_to?).with('title').and_return(false)
      allow(wt_double).to receive(:where).and_return(double(count: 0))

      errors = validate_record(rec_sin_titulo, 0, wt_double, [], [], [], [], [], false, :create)
      expect(errors.keys).to include(match(/campo title/))
    end

    it 'en modo update valida que el identifier exista' do
      allow(wt_double).to receive(:where).with(identifier: 'id1').and_return(double(count: 0))
      errors = validate_record(record, 0, wt_double, [], [], [], [], [], false, :update)
      expect(errors.keys).to include(match(/no existe en el sistema/))
    end

    it 'en modo create valida que el identifier NO exista (duplicado)' do
      allow(wt_double).to receive(:where).with(identifier: 'id1').and_return(double(count: 1))
      allow(wt_double).to receive(:where).with(isbn: anything).and_return(double(count: 0))
      errors = validate_record(record, 0, wt_double, [], [], [], [], [], false, :create)
      expect(errors.keys).to include(match(/ya existe en el sistema/))
    end
  end
end
