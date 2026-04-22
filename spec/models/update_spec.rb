require 'rails_helper'

RSpec.describe Update, type: :model do
  describe 'creacion' do
    it 'crea un registro valido con todos los campos' do
      update = Update.new(
        name: 'sip_prueba_update', object_type: 'Book',
        depositor: 'user@colmex.mx', date: DateTime.now.utc,
        storage_size: '12.5', status: 'Procesando...',
        num_records: 3, repnal: 'No',
        object_ids: '[["id1","Actualizado exitosamente"]]',
        changes_log: '[{"identifier":"id1","status":"Actualizado exitosamente","changes":{}}]'
      )
      expect(update.save).to be true
    end

    it 'guarda con campos opcionales en nil' do
      update = Update.create!(name: 'sip_prueba_update', status: 'Procesando...')
      expect(update.id).to be_present
      expect(update.changes_log).to be_nil
      expect(update.object_ids).to be_nil
    end
  end

  describe 'status' do
    %w[Procesando... Procesado Cancelado Cancelando...].each do |estado|
      it "acepta status '#{estado}'" do
        update = Update.create!(name: 'sip', status: estado)
        expect(update.status).to eq(estado)
      end
    end
  end

  describe 'object_ids' do
    it 'persiste tuplas exitosas y erroneas' do
      data = [['id1', 'Actualizado exitosamente'], ['id2', 'El identificador no existe en el sistema']]
      update = Update.create!(name: 'sip', status: 'Procesado', object_ids: data.to_json)
      expect(JSON.parse(Update.find(update.id).object_ids)).to eq(data)
    end
  end

  describe 'changes_log' do
    it 'persiste detalle de cambios por campo' do
      log = [{ identifier: 'id1', status: 'Actualizado exitosamente',
               changes: { 'title' => { 'before' => 'Viejo', 'after' => 'Nuevo' } } }]
      update = Update.create!(name: 'sip', status: 'Procesado', changes_log: log.to_json)
      parsed = JSON.parse(Update.find(update.id).changes_log)
      expect(parsed.first['changes']['title']['after']).to eq('Nuevo')
    end

    it 'acepta changes_log vacio' do
      update = Update.create!(name: 'sip', status: 'Procesado', changes_log: '[]')
      expect(JSON.parse(update.changes_log)).to eq([])
    end

    it 'acepta changes_log nil (lotes sin detalle)' do
      update = Update.create!(name: 'sip', status: 'Procesando...')
      expect(update.changes_log).to be_nil
    end
  end
end
