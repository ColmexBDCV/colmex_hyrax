require 'rails_helper'

RSpec.describe ImportsController, type: :controller do
  let(:user) { instance_double('User', email: 'admin@colmex.mx') }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'retorna http 200 y asigna @imports' do
      Import.create!(name: 'sip_a', status: 'Procesado')
      get :index

      expect(response).to have_http_status(:ok)
      expect(controller.instance_variable_get(:@imports)).not_to be_nil
    end

    it 'usa per_page permitido cuando se envia' do
      Import.create!(name: 'sip_a', status: 'Procesado')
      get :index, params: { per_page: 20 }

      expect(controller.instance_variable_get(:@per_page)).to eq(20)
      expect(controller.instance_variable_get(:@imports).limit_value).to eq(20)
    end

    it 'usa 10 cuando per_page no es permitido' do
      Import.create!(name: 'sip_a', status: 'Procesado')
      get :index, params: { per_page: 15 }

      expect(controller.instance_variable_get(:@per_page)).to eq(10)
      expect(controller.instance_variable_get(:@imports).limit_value).to eq(10)
    end
  end

  describe 'POST #validate' do
    let(:sip)  { 'mi_sip' }
    let(:work) { 'Book' }

    before do
      allow(controller).to receive(:get_size_sip).and_return(100.0)
      allow(controller).to receive(:disk_free_mb).and_return(1000.0)
      allow(controller).to receive(:validate_csv).and_return({ ok: true })
    end

    context 'cuando hay una importación en proceso' do
      it 'devuelve error JSON para status Procesando...' do
        Import.create!(name: 'corriendo', status: 'Procesando...')
        post :validate, params: { sip: sip, work: work }

        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json['Error']).to include('importación en proceso')
      end

      it 'no devuelve error si la importación existente está Procesada' do
        Import.create!(name: 'lista', status: 'Procesado')
        post :validate, params: { sip: sip, work: work }

        json = JSON.parse(response.body)
        expect(json).not_to have_key('Error')
      end
    end

    context 'cuando el espacio libre en /datos es insuficiente (solo producción)' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        allow(controller).to receive(:get_size_sip).and_return(100.0)
        allow(controller).to receive(:disk_free_mb).and_return(200.0) # 200 MB < 300 (3x100)
      end

      it 'devuelve error JSON indicando espacio insuficiente' do
        post :validate, params: { sip: sip, work: work }

        json = JSON.parse(response.body)
        expect(json['Error']).to include('Espacio insuficiente')
      end

      it 'no llama a validate_csv' do
        expect(controller).not_to receive(:validate_csv)
        post :validate, params: { sip: sip, work: work }
      end
    end

    context 'cuando el espacio es exactamente el mínimo requerido (solo producción)' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        allow(controller).to receive(:get_size_sip).and_return(100.0)
        allow(controller).to receive(:disk_free_mb).and_return(300.0) # exactamente 3x
      end

      it 'permite continuar la validación' do
        post :validate, params: { sip: sip, work: work }

        json = JSON.parse(response.body)
        expect(json).not_to have_key('Error')
      end
    end

    context 'cuando todas las condiciones se cumplen' do
      it 'devuelve el resultado de validate_csv' do
        post :validate, params: { sip: sip, work: work }

        json = JSON.parse(response.body)
        expect(json['ok']).to be true
      end

      it 'llama a validate_csv con los params correctos' do
        expect(controller).to receive(:validate_csv).with(sip, work, nil).and_return({})
        post :validate, params: { sip: sip, work: work }
      end

      it 'omite la validación de disco fuera de producción' do
        expect(controller).not_to receive(:disk_free_mb)
        post :validate, params: { sip: sip, work: work }
      end
    end
  end
end