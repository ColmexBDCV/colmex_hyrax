# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ColmexRecordImporter do
  let(:user) { User.new(email: 'user@example.com') }
  let(:collection) { instance_double(Collection, id: 'col-001') }
  let(:file_set) { instance_double(FileSet, id: 'fs-001', label: 'test.pdf', visibility: 'open') }

  let(:base_opts) do
    {
      creator: user,
      file_path: '/tmp/',
      work: 'GenericWork',
      collection: 'TestCollection'
    }
  end

  before do
    allow(Collection).to receive(:where).and_return([collection])
  end

  subject(:importer) { described_class.new(**base_opts) }

  # ---------------------------------------------------------------------------
  # access_file_set — comportamiento central corregido
  # ---------------------------------------------------------------------------
  describe '#access_file_set (via send)' do
    let(:fs) do
      instance_double(FileSet,
                      id: 'fs-001',
                      label: 'archivo.pdf',
                      visibility: 'open',
                      'visibility=' => nil,
                      save: true)
    end

    before do
      allow(FileSet).to receive(:find).with('fs-001').and_return(fs)
      allow(RecordChangeLog).to receive(:create)
    end

    context 'cuando item_access_restrictions es nil' do
      it 'deja el fileset como open' do
        expect(fs).to receive(:visibility=).with('open')
        importer.send(:access_file_set, 'fs-001', nil)
      end
    end

    context 'cuando item_access_restrictions es un array vacío []' do
      it 'deja el fileset como open' do
        expect(fs).to receive(:visibility=).with('open')
        importer.send(:access_file_set, 'fs-001', [])
      end
    end

    context 'cuando item_access_restrictions tiene contenido' do
      it 'marca el fileset como restricted' do
        expect(fs).to receive(:visibility=).with('restricted')
        importer.send(:access_file_set, 'fs-001', ['Acceso restringido'])
      end
    end

    context 'cuando item_access_restrictions es un string no vacío' do
      it 'marca el fileset como restricted' do
        expect(fs).to receive(:visibility=).with('restricted')
        importer.send(:access_file_set, 'fs-001', 'Restringido')
      end
    end

    context 'cuando item_access_restrictions es string vacío ""' do
      # String vacío NO es nil ni [], por tanto el importer lo trata como
      # contenido presente → restricted. Este caso documenta el comportamiento
      # actual; si se desea tratarlo como open habría que ampliar la condición.
      it 'marca el fileset como restricted (string vacío no es nil ni [])' do
        expect(fs).to receive(:visibility=).with('restricted')
        importer.send(:access_file_set, 'fs-001', '')
      end
    end
  end

  # ---------------------------------------------------------------------------
  # create_for — integración del fix: sin .to_s al pasar item_access_restrictions
  # ---------------------------------------------------------------------------
  describe '#create_for' do
    let(:record) do
      double(
        'record',
        identifier: ['test-id-001'],
        title: 'Obra de prueba',
        representative_file: nil,
        respond_to?: false,
        attributes: { title: ['Obra de prueba'], item_access_restrictions: nil }
      )
    end

    let(:work_instance) { instance_double(GenericWork, id: 'work-001', class: GenericWork) }

    before do
      allow(GenericWork).to receive(:where).with(identifier: record.identifier).and_return([])
      allow(importer).to receive(:import_type).and_return(GenericWork)
      allow(GenericWork).to receive(:new).and_return(work_instance)

      env_double = instance_double(Hyrax::Actors::Environment)
      allow(Hyrax::Actors::Environment).to receive(:new).and_return(env_double)
      allow(Hyrax::CurationConcern).to receive_message_chain(:actor, :create).and_return(true)

      allow(GenericWork).to receive(:find).with('work-001').and_return(work_instance)
      allow(work_instance).to receive(:file_set_ids).and_return(['fs-001'])

      allow(FileSet).to receive(:find).with('fs-001').and_return(file_set)
      allow(file_set).to receive(:visibility=)
      allow(file_set).to receive(:save).and_return(true)
      allow(RecordChangeLog).to receive(:create)
    end

    context 'cuando item_access_restrictions es nil en el CSV' do
      it 'llama a access_file_set con nil (no con string vacío)' do
        expect(importer).to receive(:access_file_set).with('fs-001', nil)
        importer.send(:create_for, record: record)
      end

      it 'pone el fileset en open' do
        expect(file_set).to receive(:visibility=).with('open')
        importer.send(:create_for, record: record)
      end
    end

    context 'cuando item_access_restrictions tiene valor en el CSV' do
      let(:record) do
        double(
          'record',
          identifier: ['test-id-002'],
          title: 'Obra restringida',
          representative_file: nil,
          respond_to?: false,
          attributes: { title: ['Obra restringida'], item_access_restrictions: ['Solo investigadores'] }
        )
      end

      before do
        allow(GenericWork).to receive(:where).with(identifier: record.identifier).and_return([])
      end

      it 'llama a access_file_set con el valor del campo' do
        expect(importer).to receive(:access_file_set).with('fs-001', ['Solo investigadores'])
        importer.send(:create_for, record: record)
      end

      it 'pone el fileset en restricted' do
        expect(file_set).to receive(:visibility=).with('restricted')
        importer.send(:create_for, record: record)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # normalize_value y value_empty? — helpers de detección de cambios
  # ---------------------------------------------------------------------------
  describe '#normalize_value' do
    it 'retorna nil para nil' do
      expect(importer.send(:normalize_value, nil)).to be_nil
    end

    it 'retorna [] para array vacío' do
      expect(importer.send(:normalize_value, [])).to eq([])
    end

    it 'ordena y limpia los elementos de un array' do
      expect(importer.send(:normalize_value, [' b ', 'a'])).to eq(['a', 'b'])
    end

    it 'elimina espacios de strings' do
      expect(importer.send(:normalize_value, '  hola  ')).to eq('hola')
    end
  end

  describe '#value_empty?' do
    it 'retorna true para nil'  do
      expect(importer.send(:value_empty?, nil)).to be true
    end

    it 'retorna true para []' do
      expect(importer.send(:value_empty?, [])).to be true
    end

    it 'retorna true para string vacío' do
      expect(importer.send(:value_empty?, '')).to be true
    end

    it 'retorna false para array con contenido' do
      expect(importer.send(:value_empty?, ['algo'])).to be false
    end

    it 'retorna false para string con contenido' do
      expect(importer.send(:value_empty?, 'algo')).to be false
    end
  end

  describe '#update_for' do
    let(:record) do
      double(
        'record',
        identifier: 'id-update-001',
        attributes: {},
        representative_file: ['nuevo.pdf']
      )
    end

    let(:gw_class) { double('GenericWorkClass') }
    let(:gw) do
      double(
        'existing_work',
        id: 'work-001',
        identifier: 'id-update-001',
        file_set_ids: ['fs-old'],
        has_model: ['GenericWork'],
        save: true
      )
    end
    let(:persisted_gw) { double('persisted_work') }
    let(:reloaded_gw) { double('reloaded_work', file_set_ids: ['fs-new']) }
    let(:old_file_set) { double('old_file_set', label: 'anterior.pdf', destroy: true) }
    let(:new_file_set) { double('new_file_set', label: 'nuevo.pdf') }
    let(:log_entry) { double('log_entry', save: true) }

    before do
      allow(GenericWork).to receive(:where).with(identifier: 'id-update-001').and_return([gw])
      allow(gw).to receive(:class).and_return(gw_class)
      allow(gw_class).to receive(:name).and_return('GenericWork')
      allow(gw_class).to receive(:find).with('work-001').and_return(persisted_gw, reloaded_gw)

      allow(importer).to receive(:capture_work_metadata).with(persisted_gw).and_return({})
      allow(importer).to receive(:capture_work_metadata).with(gw).and_return({})
      allow(importer).to receive(:get_metadata_changes).and_return({})
      allow(importer).to receive(:replace_file_set).with('nuevo.pdf', gw)
      allow(importer).to receive(:access_file_set)

      allow(gw).to receive(:item_access_restrictions=)
      allow(FileSet).to receive(:find).with('fs-old').and_return(old_file_set)
      allow(FileSet).to receive(:find).with('fs-new').and_return(new_file_set)
      allow(RecordChangeLog).to receive(:new).and_return(log_entry)
    end

    it 'agrega file_name al log con los labels antes y despues del reemplazo' do
      result = importer.send(:update_for, record: record)

      expect(result[2]['file_name']).to eq(
        before: ['anterior.pdf'],
        after: ['nuevo.pdf']
      )
    end
  end
end
