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
end