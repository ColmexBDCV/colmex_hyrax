require 'rails_helper'
require 'csv'

RSpec.describe ExportCsvJob, type: :job do
  let(:sip_name) { 'sip_prueba_update' }
  let(:sip_path) { "digital_objects/#{sip_name}" }
  let(:batch_date) { '2026-04-21T00:45:33Z' }

  after do
    FileUtils.rm_rf(sip_path) if File.directory?(sip_path)
  end

  describe '#perform con log_entries (modo update)' do
    let(:log_entries) do
      [
        { 'identifier' => 'id1', 'status' => 'Actualizado exitosamente',
          'changes' => {
            'title'       => { 'before' => 'Titulo viejo', 'after' => 'Titulo nuevo' },
            'description' => { 'before' => ['Desc vieja'], 'after' => ['Desc nueva'] }
          }
        },
        { 'identifier' => 'id2', 'status' => 'El identificador no existe en el sistema',
          'changes' => nil
        },
        { 'identifier' => 'id3', 'status' => 'Error: RSolr::Error::Http: 400',
          'changes' => { 'error_class' => 'RSolr::Error::Http', 'error_message' => '400' }
        }
      ]
    end

    before { ExportCsvJob.perform_now(sip_name, 'Book', [], log_entries, batch_date) }

    let(:csv_file) do
      Dir["#{sip_path}/log_*.csv"].first
    end

    it 'genera el archivo CSV' do
      expect(csv_file).to be_present
    end

    it 'el nombre incluye el nombre del sip y la fecha del lote' do
      expect(File.basename(csv_file)).to match(/^log_sip_prueba_update_20260421/)
    end

    it 'incluye columnas identifier y estado' do
      headers = CSV.read(csv_file, headers: true).headers
      expect(headers).to include('identifier', 'estado')
    end

    it 'genera columnas _antes y _despues por cada campo cambiado' do
      headers = CSV.read(csv_file, headers: true).headers
      expect(headers).to include('title_antes', 'title_despues', 'description_antes', 'description_despues')
    end

    it 'escribe los valores correctos para el registro exitoso' do
      row = CSV.read(csv_file, headers: true).find { |r| r['identifier'] == 'id1' }
      expect(row['estado']).to eq('Actualizado exitosamente')
      expect(row['title_antes']).to eq('Titulo viejo')
      expect(row['title_despues']).to eq('Titulo nuevo')
    end

    it 'escribe celdas vacias para registro sin cambios' do
      row = CSV.read(csv_file, headers: true).find { |r| r['identifier'] == 'id2' }
      expect(row['estado']).to eq('El identificador no existe en el sistema')
      expect(row['title_antes']).to eq('')
      expect(row['title_despues']).to eq('')
    end

    it 'une valores de array con pipe' do
      row = CSV.read(csv_file, headers: true).find { |r| r['identifier'] == 'id1' }
      expect(row['description_antes']).to eq('Desc vieja')
      expect(row['description_despues']).to eq('Desc nueva')
    end

    it 'genera todas las filas (exitosas, fallidas y con error)' do
      rows = CSV.read(csv_file, headers: true)
      expect(rows.count).to eq(3)
    end

    it 'usa la fecha del lote en el nombre del archivo, no Time.current' do
      expect(File.basename(csv_file)).to include('20260421_004533')
    end
  end

  describe '#perform con log_entries vacio' do
    it 'no genera CSV si no hay entries' do
      ExportCsvJob.perform_now(sip_name, 'Book', [], [], batch_date)
      expect(Dir["#{sip_path}/log_*.csv"]).to be_empty
    end
  end

  describe '#perform sin log_entries (modo import legacy)' do
    it 'delega a ExporterService sin llamar export_update_log' do
      allow(Book).to receive(:where).with(identifier: 'id1').and_return([double(id: 'abc123')])
      allow(ExporterService).to receive(:export)
      ExportCsvJob.perform_now(sip_name, 'Book', ['id1'])
      expect(ExporterService).to have_received(:export)
    end
  end

  describe 'nombre del archivo' do
    it 'usa Time.current como fallback si batch_date es nil' do
      log_entries = [{ 'identifier' => 'id1', 'status' => 'Actualizado exitosamente', 'changes' => {} }]
      ExportCsvJob.perform_now(sip_name, 'Book', [], log_entries, nil)
      csv = Dir["#{sip_path}/log_*.csv"].first
      expect(csv).to be_present
    end

    it 'sanitiza caracteres especiales en el nombre del sip' do
      sip_raro = 'sip raro & update'
      ExportCsvJob.perform_now(sip_raro, 'Book', [],
        [{ 'identifier' => 'id1', 'status' => 'ok', 'changes' => {} }], batch_date)
      csv = Dir["digital_objects/#{sip_raro}/log_*.csv"].first
      expect(File.basename(csv)).not_to include(' ', '&')
    ensure
      FileUtils.rm_rf("digital_objects/#{sip_raro}")
    end
  end
end
