require 'rails_helper'

RSpec.describe Dashboard::ExportsController, type: :controller do
  let(:admin) { instance_double('User', id: 999, admin?: true, persisted?: true) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(admin)
    allow(Collection).to receive(:all).and_return([])
    allow(controller).to receive(:thematic_collection_values).and_return([])
  end

  describe 'GET #index' do
    it 'responde correctamente para administradores' do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    it 'encola exportacion por tipo de trabajo' do
      expect(ExportByWorkTypeJob).to receive(:perform_later).with('GenericWork', 'title identifier')

      post :create, params: { export_type: 'by_work_type', work_type: 'GenericWork', fields: 'title identifier' }

      expect(response).to redirect_to(dashboard_exports_path)
    end

    it 'encola exportacion por coleccion' do
      expect(ExportByCollectionJob).to receive(:perform_later).with('Coleccion A', 'title')

      post :create, params: { export_type: 'by_collection', collection: 'Coleccion A', fields: 'title' }

      expect(response).to redirect_to(dashboard_exports_path)
    end

    it 'encola exportacion por campo' do
      expect(ExportByFieldJob).to receive(:perform_later).with('ABC', 'identifier', 'title')

      post :create, params: { export_type: 'by_field', value: 'ABC', key: 'identifier', fields: 'title' }

      expect(response).to redirect_to(dashboard_exports_path)
    end

    it 'encola exportacion por coleccion tematica usando el parametro thematic_collection' do
      expect(ExportByThematicCollectionJob).to receive(:perform_later).with('Produccion Institucional', 'title')

      post :create, params: { export_type: 'by_thematic_collection', thematic_collection: 'Produccion Institucional', fields: 'title' }

      expect(response).to redirect_to(dashboard_exports_path)
    end

    it 'encola exportacion por coleccion tematica con fallback al parametro collection' do
      expect(ExportByThematicCollectionJob).to receive(:perform_later).with('Produccion Institucional', 'title')

      post :create, params: { export_type: 'by_thematic_collection', collection: 'Produccion Institucional', fields: 'title' }

      expect(response).to redirect_to(dashboard_exports_path)
    end

    it 'encola exportacion de todo' do
      expect(ExportAllJob).to receive(:perform_later).with('title')

      post :create, params: { export_type: 'all', fields: 'title' }

      expect(response).to redirect_to(dashboard_exports_path)
    end

    it 'rechaza tipo de exportacion invalido' do
      post :create, params: { export_type: 'nope' }

      expect(response).to redirect_to(dashboard_exports_path)
      expect(flash[:alert]).to eq('Tipo de exportación inválido')
    end
  end

  describe 'permisos' do
    let(:admin) { instance_double('User', id: 999, admin?: false, persisted?: true) }

    it 'bloquea usuarios no administradores' do
      get :index

      expect(response).not_to have_http_status(:ok)
    end
  end
end
