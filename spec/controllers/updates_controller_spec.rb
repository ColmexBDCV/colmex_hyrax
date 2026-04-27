require 'rails_helper'

RSpec.describe UpdatesController, type: :controller do
  let(:user) { instance_double('User', email: 'admin@colmex.mx') }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'retorna http 200 y asigna @updates' do
      Update.create!(name: 'sip_a_update', status: 'Procesado')
      get :index
      expect(response).to have_http_status(:ok)
      expect(controller.instance_variable_get(:@updates)).not_to be_nil
    end

    it 'usa per_page permitido cuando se envia' do
      Update.create!(name: 'sip_a_update', status: 'Procesado')
      get :index, params: { per_page: 20 }

      expect(controller.instance_variable_get(:@per_page)).to eq(20)
      expect(controller.instance_variable_get(:@updates).limit_value).to eq(20)
    end

    it 'usa 10 cuando per_page no es permitido' do
      Update.create!(name: 'sip_a_update', status: 'Procesado')
      get :index, params: { per_page: 15 }

      expect(controller.instance_variable_get(:@per_page)).to eq(10)
      expect(controller.instance_variable_get(:@updates).limit_value).to eq(10)
    end
  end

  describe 'GET #new' do
    before do
      allow(controller).to receive(:list_sips).and_return([
        { sip: 'sip_prueba_update', size: '5.0' },
        { sip: 'sip_sin_sufijo',    size: '2.0' }
      ])
    end

    it 'filtra solo SIPs con sufijo _update' do
      get :new
      sips = controller.instance_variable_get(:@sips)
      expect(sips.map { |s| s[:sip] }).to all(end_with('_update'))
    end

    it 'retorna http 200' do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #validate' do
    before do
      allow(controller).to receive(:validate_csv_update).and_return({ 'success' => ['id1'] })
    end

    it 'rechaza SIP sin sufijo _update' do
      post :validate, params: { sip: 'sip_sin_sufijo', work: 'Book' }
      body = JSON.parse(response.body)
      expect(body).to have_key('Error')
    end

    it 'acepta SIP con sufijo _update y delega a validate_csv_update' do
      post :validate, params: { sip: 'sip_prueba_update', work: 'Book' }
      body = JSON.parse(response.body)
      expect(body).to have_key('success')
    end

    it 'devuelve error cuando validate_csv_update falla' do
      allow(controller).to receive(:validate_csv_update).and_return({ Error: 'No existe carpeta metadatos' })
      post :validate, params: { sip: 'sip_prueba_update', work: 'Book' }
      body = JSON.parse(response.body)
      expect(body.keys.map(&:to_s)).to include('Error')
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        update: {
          name: 'sip_prueba_update', object_type: 'Book',
          storage_size: '5.0', identifiers: ['id1', 'id2']
        }
      }
    end

    before { allow(UpdateCreateJob).to receive(:perform_later) }

    it 'crea Update y encola UpdateCreateJob' do
      expect(UpdateCreateJob).to receive(:perform_later)
      post :create, params: valid_params, format: :json
      expect(Update.last.status).to eq('Procesando...')
      expect(Update.last.depositor).to eq('admin@colmex.mx')
    end

    it 'guarda num_records igual al numero de identifiers' do
      post :create, params: valid_params, format: :json
      expect(Update.last.num_records).to eq(2)
    end

    it 'guarda date en formato ISO parseable' do
      post :create, params: valid_params, format: :json
      expect { DateTime.parse(Update.last.date.to_s) }.not_to raise_error
    end

    it 'no permite mass-assignment del id primario' do
      params_con_id = valid_params.deep_merge(update: { id: 9999 })
      post :create, params: params_con_id, format: :json
      expect(Update.find_by(id: 9999)).to be_nil
    end

    it 'guarda repnal como Si cuando se envia el param' do
      post :create, params: valid_params.deep_merge(update: { repnal: 'true' }), format: :json
      expect(Update.last.repnal).to eq('Si')
    end

    it 'guarda repnal como No cuando no se envia el param' do
      post :create, params: valid_params, format: :json
      expect(Update.last.repnal).to eq('No')
    end
  end
end
